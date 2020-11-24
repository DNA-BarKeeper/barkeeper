namespace :data do
  task :check_completion_of_taxon, %i[taxonomic_order] => :environment do |_t, args|
    Marker.gbol.each do |marker|
      completed_count = 0
      species_cnt = 0

      Order.find_by_name(args[:taxonomic_order]).families.each do |family|
        species_cnt += family.species.size
        family.species.includes(individuals: [isolates: :marker_sequences]).each do |s|
          has_ms = false
          s.individuals.each do |i|
            i.isolates.each do |iso|
              has_ms = iso.marker_sequences.joins(:contigs).where(marker_id: marker.id).where(contigs: { verified: true} ).any? ? true : has_ms
            end
          end
          completed_count += 1 if has_ms
        end
      end

      puts "Number of completed species for marker #{marker.name}: #{completed_count}/#{species_cnt}"
    end
  end

  task :check_collection_of_taxon, %i[taxonomic_order] => :environment do |_t, args|
    completed_count = 0
    species_cnt = 0

    Order.find_by_name(args[:taxonomic_order]).families.each do |family|
      species_cnt += family.species.size
      family.species.includes(:individuals).each do |s|
        has_specimen = s.individuals.size.positive?
        completed_count += 1 if has_specimen
      end
    end

    puts "Number of species with at least one specimen: #{completed_count}/#{species_cnt}"
  end
end