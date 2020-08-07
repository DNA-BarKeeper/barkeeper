namespace :data do
  task remove_old_exports: :environment do
    # Delete all specimen exports older than 1 week
    old_specimen_exports = SpecimenExporter.where('created_at < ?', 7.days.ago)
    puts "#{old_specimen_exports.size} specimen records will be removed."
    old_specimen_exports.destroy_all

    # Delete all species exports older than 1 month
    old_species_exports = SpeciesExporter.where('created_at < ?', 1.month.ago)
    puts "#{old_species_exports.size} species records will be removed."
    old_species_exports.destroy_all
  end
end