class ContigPdeUploader < ActiveRecord::Base
  include ActionView::Helpers

  require 'zip'
  require 'fileutils'

  has_attached_file :uploaded_file,
                    :storage => :s3,
                    :s3_credentials => Proc.new{ |a| a.instance.s3_credentials },
                    :s3_region => 'eu-west-1',
                    :path => "/caryophyllales_matK_contigs_that_need_verification.zip"

  # Validate content type
  validates_attachment_content_type :uploaded_file, :content_type => /\Aapplication\/zip/

  # Validate filename
  validates_attachment_file_name :uploaded_file, :matches => [/zip\Z/]

  def s3_credentials
    {:bucket => "gbol5", :access_key_id => "AKIAINH5TDSKSWQ6J62A", :secret_access_key => "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"}
  end

  def create_uploaded_file
    temp_folder = "#{Rails.root}/tmp/contigs_caryo_matK"
    archive_file = "#{Rails.root}/tmp/contigs_caryo_matK.zip"
    Dir.mkdir("#{temp_folder}") if !File.exists?(temp_folder)
    FileUtils.rm_r "#{temp_folder}" if File.exists?(archive_file)

    caryo_matK_contigs = Contig.caryo_matK.need_verification

    Zip::File.open(archive_file, Zip::File::CREATE) do |zipfile|
      caryo_matK_contigs.each do |contig|
          File.open("#{temp_folder}/#{contig.name}.pde", 'w') { |file| file.write("#{contig.pde}") }
          zipfile.add("#{contig.name}.pde", "#{temp_folder}/#{contig.name}.pde")

          contig.primer_reads.each do |read|
            url = "http:#{read.chromatogram.url}"
            File.open("#{temp_folder}/#{read.name}", 'w') { |file| file.write(URI.parse(url).read.force_encoding(Encoding::UTF_8)) }
            zipfile.add(read.name, "#{temp_folder}/#{read.name}")
          end
      end
    end

    FileUtils.rm_r "#{temp_folder}" if File.exists?(temp_folder)

    self.uploaded_file = File.open("contigs_caryo_matK.zip")
    self.save!
  end
end