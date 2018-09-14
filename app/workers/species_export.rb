# frozen_string_literal: true

# Worker that exports tables with species data
class SpeciesExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  # Exports species data of a project specified by +project_id+ to an Excel file
  def perform(project_id)
    SpeciesXmlUploader.new.create_uploaded_file(project_id)
  end
end
