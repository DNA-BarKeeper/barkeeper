class SpeciesExport

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform

    SpeciesXmlUploader.new.create_uploaded_file

  end

end