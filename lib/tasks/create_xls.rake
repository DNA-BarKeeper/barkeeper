# frozen_string_literal: true

namespace :data do
  desc 'export specimen info to ZFMK readable xls format'
  task create_specimen_export: :environment do
    SpecimenExport.perform_async(Project.where('name ilike ?', '%gbol%').first.id)
  end

  desc 'export species info to ZFMK readable xls format'
  task create_species_export: :environment do
    SpeciesExport.perform_async(Project.where('name ilike ?', '%gbol%').first.id)
  end
end
