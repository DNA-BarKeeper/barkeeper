class XmlUploader < ActiveRecord::Base

  #todo later rename  :uploaded_file to xml_File or s.th.

  has_attached_file :uploaded_file,
                    :storage => :s3,
                    :s3_credentials => Proc.new{ |a| a.instance.s3_credentials },
                    :path => "/specimens.xml"

  # Validate content type
  validates_attachment_content_type :uploaded_file, :content_type => /\Atext\/plain/

  # Validate filename
  validates_attachment_file_name :uploaded_file, :matches => [/txt\Z/]

  def create_uploaded_file

    # xml = ::Builder::XmlMarkup.new( :indent => 2 )
    # xml.instruct! :xml, :encoding => "ASCII"
    # xml.product do |p|
    #   p.name "Test"
    # end

    file_to_upload = File.open("file_created_in_Background.txt", "w")

    file_to_upload.write(xml_string)
    file_to_upload.close()
    self.uploaded_file = File.open("file_created_in_Background.txt")
    self.save!
  end

  #todo remove s3 credentials from code everywhere

  def s3_credentials
    {:bucket => "gbol5", :access_key_id => "AKIAINH5TDSKSWQ6J62A", :secret_access_key => "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"}
  end

  def xml_string
    # get all indiv.
    @individuals=Individual.includes(:species => :family).all

    xml_string=""

  end


end