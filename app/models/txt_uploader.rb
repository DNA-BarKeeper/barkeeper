class TxtUploader < ActiveRecord::Base

  has_attached_file :uploaded_file,
                    :storage => :s3,
                    :s3_credentials => Proc.new{ |a| a.instance.s3_credentials },
                    :s3_region => ENV["eu-west-1"],
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

  #todo remove s3 credentials from code everywhere

  def s3_credentials
    {:bucket => "gbol5", :access_key_id => "AKIAINH5TDSKSWQ6J62A", :secret_access_key => "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"}
  end

end
