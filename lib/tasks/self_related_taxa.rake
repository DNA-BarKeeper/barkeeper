namespace :data do
  task transfer_divisions: :environment do
    puts "Transferring #{Division.all.size} divisions into new data structure..."

    Division.all.each do | div |
      Taxon.create(scientific_name: div.name,
                   taxonomic_rank: :is_division)
    end

    puts "Done."
  end

  task transfer_subdivisions: :environment do
    puts "Transferring #{Subdivision.all.size} subdivisions into new data structure..."

    Subdivision.all.each do | subdiv |
      parent = Taxon.find_by_scientic_name(subdiv.division.name)

      Taxon.create(common_name: subdiv.german_name,
                   scientific_name: subdiv.name,
                   position: subdiv.position,
                   taxonomic_rank: :is_subdivision,
                   parent: parent)
    end

    puts "Done."
  end

  task transfer_taxonomic_classes: :environment do
    puts "Transferring #{TaxonomicClass.all.size} classes into new data structure..."

    TaxonomicClass.all.each do | tc |
      parent = Taxon.find_by_scientic_name(tc.subdivision.name)

      Taxon.create(common_name: tc.german_name,
                   scientific_name: tc.name,
                   taxonomic_rank: :is_class,
                   parent: parent)
    end

    puts "Done."
  end

  task transfer_orders: :environment do
    puts "Transferring #{Order.all.size} orders into new data structure..."

    Order.all.each do | order |
      parent = Taxon.find_by_scientic_name(order.taxonomic_class.name)

      Taxon.create(author: order.author,
                   scientific_name: order.name,
                   taxonomic_rank: :is_order,
                   parent: parent)
    end

    puts "Done."
  end

  task transfer_families: :environment do
    puts "Transferring #{Family.all.size} families into new data structure..."

    Family.all.each do | family |
      parent = Taxon.find_by_scientic_name(family.order.name)

      Taxon.create(author: family.author,
                   scientific_name: family.name,
                   taxonomic_rank: :is_family,
                   parent: parent)
    end

    puts "Done."
  end

  task transfer_species: :environment do
    puts "Transferring #{Species.all.size} species into new data structure..."

    Species.all.each do | species |
      # Create genus
      family = Taxon.find_by_scientic_name(species.family.name)
      genus = Taxon.find_or_create_by(scientific_name: species.genus_name,
                                      taxonomic_rank: :is_genus,
                                      parent: family)

      # Create species
      species = Taxon.find_or_create_by(scientific_name: species.species_component,
                                        author: species.author,
                                        comment: species.comment,
                                        common_name: species.german_name,
                                        synonym: species.synonym,
                                        taxonomic_rank: :is_species,
                                        parent: genus)

      unless species.infraspecific.blank?
        # Create subspecific record
        Taxon.create(author: species.author_infra,
                     comment: species.comment,
                     common_name: species.german_name,
                     scientific_name: species.composed_name,
                     synonym: species.synonym,
                     taxonomic_rank: :is_subspecies,
                     parent: species)
      end
    end

    puts "Done."
  end

  task add_project_to_taxa: :environment do
    Taxon.all.each do | taxon |
      taxon.add_project(5) # Adds GBOL5 project (and "all records")
    end
  end
end
