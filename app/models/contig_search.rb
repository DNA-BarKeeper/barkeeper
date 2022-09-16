#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

# frozen_string_literal: true

class ContigSearch < ApplicationRecord
  include Export

  belongs_to :user
  belongs_to :project

  validates :title, uniqueness: { :allow_blank => true,
                                  :scope=> :user_id }

  enum has_warnings: %i[both yes no]
  enum has_issues: %i[all_issue issues no_issues]

  has_one_attached :search_result_archive
  validates :search_result_archive, content_type: :zip

  def contigs
    @contigs ||= find_contigs
  end

  def create_search_result_archive
    archive_name = title.empty? ? "contig_search_#{created_at}" : title
    temp_folder = "#{Rails.root}/tmp/#{archive_name}"
    archive_file = "#{Rails.root}/tmp/#{archive_name}.zip"

    Dir.mkdir("#{temp_folder}") unless File.exists?(temp_folder)
    FileUtils.rm_r archive_file if File.exists?(archive_file)
    search_result_archive.purge if search_result_archive.attached?
    save!

    # Create archive file
    Zip::File.open(archive_file, Zip::File::CREATE) do |archive|
      contigs.each do |contig|
        # Write contig PDE to a file and add this to the zip file
        contig_filename = "#{contig.name}.pde"
        File.open("#{temp_folder}/#{contig_filename}", 'w') do |file|
          file.write(Contig.pde([contig], add_reads: true))
        end
        archive.add(contig_filename, "#{temp_folder}/#{contig_filename}")

        # Write each chromatogram to a file and add this to the zip file
        contig.primer_reads.each do |read|
          chromatogram_filename = read.chromatogram.filename.to_s
          File.open("#{temp_folder}/#{chromatogram_filename}", 'wb') do |file|
            file.write(read.chromatogram.blob.download)
          end

          begin
            archive.add(chromatogram_filename, "#{temp_folder}/#{chromatogram_filename}")
          rescue Zip::EntryExistsError
            # Do not add duplicate files
          end
        end
      end
    end

    # Upload created archive
    self.search_result_archive.attach(io: File.open(archive_file), filename: "#{archive_name}.zip", content_type: 'application/zip')
    save!

    # Remove temp directory
    FileUtils.rm_r temp_folder if File.exists?(temp_folder)
  end

  private

  def find_contigs
    contigs = Contig.in_project(user.default_project_id).order(:name)
    contigs = contigs.where('contigs.name ilike ?', "%#{name}%") if name.present?

    if assembled != 'both'
      contigs = contigs.assembled if assembled == 'assembled'
      contigs = contigs.not_assembled if assembled == 'unassembled'
    end

    if verified != 'both'
      contigs = contigs.verified if verified == 'verified'
      contigs = contigs.where(verified: false) if verified == 'unverified'
    end

    if has_warnings != 'both'
      contigs = contigs.unsolved_warnings if has_warnings == 'yes'
      contigs = contigs.where.not(id: Contig.unsolved_warnings.pluck(:id)) if has_warnings == 'no'
    end

    if has_issues != 'all_issue'
      contigs = contigs.unsolved_issues if has_issues == 'issues'
      contigs = contigs.where.not(id: Contig.unsolved_issues.pluck(:id)) if has_issues == 'no_issues'
    end

    contigs = contigs.joins(:marker).where('markers.name ilike ?', "%#{marker}%") if marker.present?

    contigs = contigs.joins(isolate: { individual: :taxon }).where('taxa.scientific_name ilike ?', "%#{taxon}%") if taxon.present?

    contigs = contigs.joins(isolate: :individual).where('individuals.specimen_id ilike ?', "%#{specimen}%") if specimen.present?

    contigs = contigs.where('contigs.verified_by = ?', User.find_by_name(verified_by)&.id) if verified_by.present?

    contigs = contigs.where('contigs.created_at >= ?', min_age.midnight) if min_age.present?
    contigs = contigs.where('contigs.created_at <= ?', max_age.end_of_day) if max_age.present?

    contigs = contigs.where('contigs.updated_at >= ?', min_update.midnight) if min_update.present?
    contigs = contigs.where('contigs.updated_at <= ?', max_update.end_of_day) if max_update.present?

    contigs
  end
end
