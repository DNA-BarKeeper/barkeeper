# frozen_string_literal: true

# Worker that exports tables with individual and marker sequence data
class SpecimenExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  # Exports individual and marker sequence data of a project specified by +project_id+ to an Excel file
  def perform(project_id)
    XmlUploader.new.create_uploaded_file(project_id)
  end
end
