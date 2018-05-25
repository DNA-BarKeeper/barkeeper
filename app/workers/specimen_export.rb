class SpecimenExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id)
    XmlUploader.new.create_uploaded_file(project_id)
  end
end