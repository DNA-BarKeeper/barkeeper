namespace :data do
  task transfer_taxonomy: :environment do
    transfer_higher_order_taxa
    transfer_divisions
    transfer_subdivisions
    transfer_taxonomic_classes
    transfer_orders
    transfer_families
    transfer_species
  end

  task add_project_to_taxa: :environment do
    Taxon.all.each do | taxon |
      taxon.add_project(5) # Adds GBOL5 project (and "all records")
    end
  end

  def transfer_higher_order_taxa
    puts "Transferring #{HigherOrderTaxon.all.size} higher order taxa into new data structure..."

    HigherOrderTaxon.all.each do | hot |
      Taxon.create(ancestry: hot.ancestry,
                   scientific_name: hot.name,
                   common_name: hot.german_name,
                   position: hot.position,
                   taxonomic_rank: :is_unranked)
    end

    puts "Done."
  end

  def transfer_divisions
    puts "Transferring #{Division.all.size} divisions into new data structure..."

    Division.all.each do | div |
      Taxon.create(scientific_name: div.name,
                   taxonomic_rank: :is_division)
    end

    puts "Done."
  end

  def transfer_subdivisions
    puts "Transferring #{Subdivision.all.size} subdivisions into new data structure..."

    Subdivision.all.each do | subdiv |
      parent = Taxon.find_by_scientific_name(subdiv.division.name) if subdiv.division

      Taxon.create(common_name: subdiv.german_name,
                   scientific_name: subdiv.name,
                   position: subdiv.position,
                   taxonomic_rank: :is_subdivision,
                   parent: parent)
    end

    puts "Done."
  end

  def transfer_taxonomic_classes
    puts "Transferring #{TaxonomicClass.all.size} classes into new data structure..."

    TaxonomicClass.all.each do | tc |
      parent = Taxon.find_by_scientific_name(tc.subdivision.name) if tc.subdivision

      Taxon.create(common_name: tc.german_name,
                   scientific_name: tc.name,
                   taxonomic_rank: :is_class,
                   parent: parent)
    end

    puts "Done."
  end

  def transfer_orders
    puts "Transferring #{Order.all.size} orders into new data structure..."

    Order.all.each do | order |
      parent = Taxon.find_by_scientific_name(order.taxonomic_class.name) if order.taxonomic_class

      Taxon.create(author: order.author,
                   scientific_name: order.name,
                   taxonomic_rank: :is_order,
                   parent: parent)
    end

    puts "Done."
  end

  def transfer_families
    puts "Transferring #{Family.all.size} families into new data structure..."

    Family.all.each do | family |
      parent = Taxon.find_by_scientific_name(family.order.name) if family.order

      Taxon.create(author: family.author,
                   scientific_name: family.name,
                   taxonomic_rank: :is_family,
                   parent: parent)
    end

    puts "Done."
  end

  def transfer_species
    puts "Transferring #{Species.all.size} species into new data structure..."

    Species.all.each do | orig_species |
      # Create genus
      family = Taxon.find_by_scientific_name(orig_species.family.name) if orig_species.family
      genus = Taxon.find_or_create_by(scientific_name: orig_species.genus_name,
                                      taxonomic_rank: :is_genus)
      genus.update(parent: family) if family

      # Create species
      comment = orig_species.comment unless orig_species.infraspecific
      species = Taxon.find_or_create_by(scientific_name: orig_species.species_component,
                                        author: orig_species.author,
                                        comment: comment,
                                        common_name: orig_species.german_name,
                                        synonym: orig_species.synonym,
                                        taxonomic_rank: :is_species)
      species.update(parent: genus)

      unless orig_species.infraspecific.blank?
        # Create subspecific record
        parent_species = Taxon.find_by_scientific_name(orig_species.species_component)
        Taxon.create(author: orig_species.author_infra,
                     comment: orig_species.comment,
                     common_name: orig_species.german_name,
                     scientific_name: orig_species.composed_name,
                     synonym: orig_species.synonym,
                     taxonomic_rank: :is_subspecies,
                     parent: parent_species)
      end
    end

    puts "Done."
  end
end
