namespace :data do
  desc 'Update PgSearch Document table'
  task update_search_index: :environment do
    PgSearch::Multisearch.rebuild(Contig)
    PgSearch::Multisearch.rebuild(Freezer)
    PgSearch::Multisearch.rebuild(Herbarium)
    PgSearch::Multisearch.rebuild(Individual)
    PgSearch::Multisearch.rebuild(Isolate)
    PgSearch::Multisearch.rebuild(Lab)
    PgSearch::Multisearch.rebuild(LabRack)
    PgSearch::Multisearch.rebuild(Marker)
    PgSearch::Multisearch.rebuild(MicronicPlate)
    PgSearch::Multisearch.rebuild(NgsRun)
    PgSearch::Multisearch.rebuild(PlantPlate)
    PgSearch::Multisearch.rebuild(Primer)
    PgSearch::Multisearch.rebuild(PrimerRead)
    PgSearch::Multisearch.rebuild(Shelf)
    PgSearch::Multisearch.rebuild(Taxon)
    PgSearch::Multisearch.rebuild(Tissue)
  end
end
