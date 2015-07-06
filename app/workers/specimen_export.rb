class SpecimenExport

  include Sidekiq::Worker

  def perform

    XmlUploader.new.create_uploaded_file

  end

end