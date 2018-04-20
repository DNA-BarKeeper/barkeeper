class SpecimenExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    XmlUploader.new.create_uploaded_file
  end
end