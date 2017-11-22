class ContigPdeUploader < ApplicationRecord
  include ActionView::Helpers

  require 'zip'
  require 'fileutils'

  has_attached_file :uploaded_file,
                    :path => "/caryophyllales_matK_contigs_that_need_verification.zip"

  # Validate content type
  validates_attachment_content_type :uploaded_file, :content_type => /\Aapplication\/zip/

  # Validate filename
  validates_attachment_file_name :uploaded_file, :matches => [/zip\Z/]

  def create_uploaded_file
    temp_folder = "#{Rails.root}/tmp/caryophyllales_matK_contigs_that_need_verification"
    archive_file = "#{Rails.root}/caryophyllales_matK_contigs_that_need_verification.zip"
    caryo_matK_contigs = Contig.caryo_matK.need_verification

    Dir.mkdir("#{temp_folder}") if !File.exists?(temp_folder)
    FileUtils.rm_r "#{archive_file}" if File.exists?(archive_file)

    # Create archive file
    Zip::File.open(archive_file, Zip::File::CREATE) do | archive |
      caryo_matK_contigs.each do |contig|
        # Write contig PDE to a file and add this to the zip file
        file_name = "#{contig.name}.pde"
        File.open("#{temp_folder}/#{file_name}", 'w') { | file | file.write(contig.as_pde) }
        archive.add("#{file_name}", "#{temp_folder}/#{file_name}")

        # Write chromatogram to a file and add this to the zip file
        contig.primer_reads.each do | read |
          File.open("#{temp_folder}/#{read.file_name_id}", 'wb') { | file | file.write(URI.parse("http:#{read.chromatogram.url}").read) } #todo copy files within AWS to increase performance: s3.buckets['bucket-name'].objects['source'].copy_to('target'‌​)
          archive.add(read.file_name_id, "#{temp_folder}/#{read.file_name_id}")
        end
      end
    end

    # Remove temporary folder
    FileUtils.rm_r "#{temp_folder}" if File.exists?(temp_folder)

    # Upload created archive
    self.uploaded_file = File.open(archive_file)
    self.save!
  end
end