# frozen_string_literal: true

class ContigSearch < ApplicationRecord
  include Export

  belongs_to :user
  belongs_to :project

  enum has_warnings: %i[both yes no]

  has_attached_file :search_result_archive,
                    :path => ":rails_root/contig_search_results/:filename"

  # Validate content type
  validates_attachment_content_type :search_result_archive, :content_type => /\Aapplication\/zip/

  # Validate filename
  validates_attachment_file_name :search_result_archive, :matches => %r{\.zip\Z}i

  def contigs
    @contigs ||= find_contigs
  end

  def create_search_result_archive
    archive_name = title.empty? ? "contig_search_#{created_at}" : title
    temp_folder = "#{Rails.root}/tmp/#{archive_name}"
    archive_file = "#{Rails.root}/tmp/#{archive_name}.zip"

    Dir.mkdir("#{temp_folder}") unless File.exists?(temp_folder)
    FileUtils.rm_r archive_file if File.exists?(archive_file)
    search_result_archive.destroy
    save!

    # Create archive file
    Zip::File.open(archive_file, Zip::File::CREATE) do |archive|
      contigs.each do |contig|
        # Write contig PDE to a file and add this to the zip file
        file_name = "#{contig.name}.pde"
        File.open("#{temp_folder}/#{file_name}", 'w') { |file| file.write(Contig.pde([contig], add_reads: true)) }
        archive.add(file_name, "#{temp_folder}/#{file_name}")

        # Write chromatogram to a file and add this to the zip file
        contig.primer_reads.each do |read|
          File.open("#{temp_folder}/#{read.file_name_id}", 'wb') do |file|
            file.write(URI.parse("http:#{read.chromatogram.url}").read) unless Rails.env.development?
            # TODO: copy files within AWS to increase performance: s3.buckets['bucket-name'].objects['source'].copy_to('target'‌​)
          end
          archive.add(read.file_name_id, "#{temp_folder}/#{read.file_name_id}")
        end
      end
    end

    # Upload created archive
    self.search_result_archive = File.open(archive_file)
    save!

    # Remove temporary folders
    FileUtils.rm_r temp_folder if File.exists?(temp_folder)
    FileUtils.rm archive_file if File.exists?(archive_file)
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

    contigs = contigs.joins(:marker).where('markers.name ilike ?', "%#{marker}%") if marker.present?

    contigs = contigs.joins(isolate: { individual: { species: { family: :order } } }).where('orders.name ilike ?', "%#{order}%") if order.present?

    contigs = contigs.joins(isolate: { individual: { species: :family } }).where('families.name ilike ?', "%#{family}%") if family.present?

    contigs = contigs.joins(isolate: { individual: :species }).where('species.composed_name ilike ?', "%#{species}%") if species.present?

    contigs = contigs.joins(isolate: :individual).where('individuals.specimen_id ilike ?', "%#{specimen}%") if specimen.present?

    contigs = contigs.where('contigs.verified_by = ?', User.find_by_name(verified_by)&.id) if verified_by.present?

    contigs = contigs.where('contigs.created_at >= ?', min_age.midnight) if min_age.present?
    contigs = contigs.where('contigs.created_at <= ?', max_age.end_of_day) if max_age.present?

    contigs = contigs.where('contigs.updated_at >= ?', min_update.midnight) if min_update.present?
    contigs = contigs.where('contigs.updated_at <= ?', max_update.end_of_day) if max_update.present?

    contigs
  end
end
