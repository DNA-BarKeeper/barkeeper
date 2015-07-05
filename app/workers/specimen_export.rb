class SpecimenExport

  include Sidekiq::Worker

  def perform

    xml_file = XmlUploader.new
    xml_file.create_uploaded_file

  end

end