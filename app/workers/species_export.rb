class SpeciesExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(project_id)
    SpeciesExporter.new.create_species_export(project_id)
  end
end