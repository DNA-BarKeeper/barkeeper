class ContigSearch < ApplicationRecord
  belongs_to :user
  belongs_to :project

  def contigs
    @contigs ||= find_contigs
  end

  def as_zip_file(archive_file)
    FileUtils.rm_r "#{archive_file}" if File.exists?(archive_file)

    # Create archive file
    Zip::File.open(archive_file, Zip::File::CREATE) do |archive|
      contigs.each do |contig|
        # Write contig PDE to a file and add this to the zip file
        file_name = "#{contig.name}.pde"
        archive.get_output_stream(file_name) { |file| file.write(contig.as_pde) }

        # Write chromatogram to a file and add this to the zip file
        contig.primer_reads.each do |read|
          archive.get_output_stream(read.file_name_id) { |file| file.write(URI.parse("http:#{read.chromatogram.url}").read) }
        end
      end
    end
  end

  private

  def find_contigs
    contigs = Contig.in_project(user.default_project_id).order(:name)
    contigs = contigs.where("contigs.name ilike ?", "%#{name}%") if name.present?

    if assembled != 'both'
      contigs = contigs.assembled if (assembled == 'assembled')
      contigs = contigs.not_assembled if (assembled == 'unassembled')
    end

    if verified != 'both'
      contigs = contigs.verified if (verified == 'verified')
      contigs = contigs.where(verified: false) if (verified == 'unverified')
    end

    contigs = contigs.joins(:marker).where("markers.name ilike ?", "%#{marker}%") if marker.present?

    contigs = contigs.joins(isolate: { individual: {species: {family: :order}}}).where("orders.name ilike ?", "%#{order}%") if order.present?

    contigs = contigs.joins(isolate: { individual: {species: :family}}).where("families.name ilike ?", "%#{family}%") if family.present?

    contigs = contigs.joins(isolate: { individual: :species }).where("species.composed_name ilike ?", "%#{species}%") if species.present?

    contigs = contigs.joins(isolate: :individual).where("individuals.specimen_id ilike ?", "%#{specimen}%") if specimen.present?

    contigs = contigs.where("contigs.created_at >= ?", min_age.midnight) if min_age.present?
    contigs = contigs.where("contigs.created_at <= ?", max_age.end_of_day) if max_age.present?

    contigs = contigs.where("contigs.updated_at >= ?", min_update.midnight) if min_update.present?
    contigs = contigs.where("contigs.updated_at <= ?", max_update.end_of_day) if max_update.present?

    contigs
  end
end
