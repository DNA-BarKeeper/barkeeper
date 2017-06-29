class TxtUploader < ActiveRecord::Base

  has_attached_file :uploaded_file,
                    :path => "/output.txt"

  # Validate content type
  validates_attachment_content_type :uploaded_file, :content_type => /\Atext\/plain/

  # Validate filename
  validates_attachment_file_name :uploaded_file, :matches => [/txt\Z/]

  def create_uploaded_file(text)

    file_to_upload = File.open("output.txt", "w")

    file_to_upload.write(text)
    file_to_upload.close
    self.uploaded_file = File.open("output.txt")
    self.save!

  end
end
