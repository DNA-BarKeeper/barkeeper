class SpecimenExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id)
    SpecimenExporter.new.create_specimen_export(project_id)
  end
end