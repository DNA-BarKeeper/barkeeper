namespace :data do
  task :check_completion_of_taxon, %i[taxonomic_order] => :environment do |_t, args|
    Marker.gbol.each do |marker|
      completed_count = 0
      species_cnt = 0

      Order.find_by_name(args[:taxonomic_order]).families.each do |family|
        species_cnt += family.species.size
        family.species.includes(individuals: [isolates: :marker_sequences]).each do |species|
          completed_count += 1 if species_completed?(species)
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
      family.species.includes(:individuals).each do |species|
        completed_count += 1 if specimen_available?(species)
      end
    end

    puts "Number of species with at least one specimen: #{completed_count}/#{species_cnt}"
  end

  task create_completion_csv: :environment do
    require 'csv'

    CSV.open('tmp/species_completion.csv', 'w') do |csv|
      headers =  %w(species family order has_specimen)
      headers += Marker.gbol.collect { |m| m.name + ' completed?' }

      csv << headers

      Species.includes(family: :order).each do |species|
        line = []

        line << species.species_component
        line << species.family&.name
        line << species.family&.order&.name
        line << specimen_available?(species) ? 'yes' : 'no'

        Marker.gbol.each do |marker|
          line << species_completed?(species, marker) ? 'yes' : 'no'
        end

        csv << line
      end
    end
  end

  def species_completed?(species, marker)
    has_ms = false

    species.individuals.each do |i|
      i.isolates.each do |iso|
        has_ms = iso.marker_sequences.joins(:contigs).where(marker_id: marker.id).where(contigs: { verified: true} ).any? ? true : has_ms
      end
    end

    has_ms
  end

  def specimen_available?(species)
    species.individuals.size.positive?
  end
end