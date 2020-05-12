# frozen_string_literal: true

class Species < ApplicationRecord
  extend Import
  include ProjectRecord
  include PgSearch::Model

  multisearchable against: :composed_name

  before_save :assign_display_names

  has_many :individuals
  has_many :primer_pos_on_genomes
  belongs_to :family

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    spp_cnt = Species.select(:species_component).joins(family: { order: :higher_order_taxon }).where(orders: { higher_order_taxon_id: higher_order_taxon_id }).distinct.count
    subspp_cnt = Species.select(:id).joins(family: { order: :higher_order_taxon }).where(orders: { higher_order_taxon_id: higher_order_taxon_id }).distinct.count
    [spp_cnt, subspp_cnt]
  end

  def self.import_species(file, valid_keys, project_id)
    spreadsheet = Species.open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      family = Family.find_or_create_by(name: row['family'])
      family.add_project_and_save(project_id)

      order = Order.find_or_create_by(name: row['order'])
      order.add_project_and_save(project_id)
      family.update(order_id: order.id)

      higher_order_taxon = HigherOrderTaxon.find_or_create_by(name: row['higher_order_taxon'])
      higher_order_taxon.add_project_and_save(project_id)
      order.update(higher_order_taxon_id: higher_order_taxon.id)

      # Update existing species or create new
      species = Species.find_or_create_by(id: row['id'])

      species.attributes = row.to_hash.slice(*valid_keys)
      species.family_id = family.id

      unless row['variety'].nil?
        species.infraspecific = row['variety']
        if species.comment
          species.comment += '- is a variety'
        else
          species.comment = '- is a variety'
        end
      end

      species.composed_name = species.full_name
      species.species_component = species.get_species_component

      species.add_project(project_id)

      species.save!
    end
  end

  def self.import_stuttgart(file, project_id)
    # Only direct attributes; associations are extra
    valid_keys = %w[genus_name
                    species_epithet
                    id
                    author
                    author_infra
                    infraspecific
                    comment
                    german_name]

    import_species(file, valid_keys, project_id)
  end

  def self.import_berlin(file, project_id)
    valid_keys = %w[genus_name
                    species_epithet
                    id
                    author
                    infraspecific
                    author_infra
                    comment] # Only direct attributes; associations are extra

    import_species(file, valid_keys, project_id)
  end

  # TODO: Does not assign a project to new records
  def self.import_gbolII(file)
    spreadsheet = Species.open_spreadsheet(file)
    header = spreadsheet.row(1)

    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      next unless (row['GBOL 1 oder 2?'].include? 'GBOL2') || (row['GBOL 1 oder 2?'].include? 'Nachtrag') # Only add new species
      # Add family or assign to existing:
      family = Family.find_or_create_by(name: row['Familie (sensu APG)'])

      # Add order or assign to existing
      order = Order.find_or_create_by(name: row['Ordnung (sensu APG)'])
      family.update(order_id: order.id)

      full_name = row['Arten/Unterarten']
      components = full_name.split(' ')

      species = Species.find_or_create_by(composed_name: full_name)

      species.update(family: family)
      species.update(genus_name: components.first)

      case components.size
      when 2
        species.update(species_epithet: components[1])
      when 3
        if components[1] == 'x'
          species_ep = components[1] + ' ' + components.last
          species.update(species_epithet: species_ep)
        else
          species.update(species_epithet: components[1], infraspecific: components.last)
        end
      when 4
        if components[2] == 'subsp.'
          species.update(species_epithet: components[1], infraspecific: components.last)
        else
          infraspecific = components[2] + ' ' + components.last
          species.update(species_epithet: components[1], infraspecific: infraspecific)
        end
      end

      species.update(species_component: species.get_species_component)
    end
  end

  # TODO: Does not assign a project to new records
  def self.import_stuttgart_set_class(file)
    spreadsheet = Species.open_spreadsheet(file)

    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      order = Order.find_by_name(row['order'])

      next unless order
      taxonomic_class = TaxonomicClass.find_or_create_by(name: row['class'])

      next unless taxonomic_class
      order.update(taxonomic_class_id: taxonomic_class.id)
      subdivision = Subdivision.find_or_create_by(name: row['subdivision'])

      taxonomic_class.update(subdivision_id: subdivision.id) if subdivision
    end
  end

  def assign_display_names
    self.species_component = get_species_component
    self.composed_name = full_name
  end

  def full_name
    "#{genus_name} #{species_epithet} #{infraspecific}".strip
  end

  def name_for_display
    if infraspecific.blank?
      "#{genus_name} #{species_epithet}".strip
    elsif comment&.include? '- is a variety'
      "#{genus_name} #{species_epithet} var. #{infraspecific}".strip
    else
      "#{genus_name} #{species_epithet} ssp. #{infraspecific}".strip
    end
  end

  def get_species_component
    "#{genus_name} #{species_epithet}".strip
  end

  def family_name
    family.try(:name)
  end

  def family_name=(name)
    if name == ''
      self.family = nil
    else
      self.family = Family.find_or_create_by(name: name) if name.present? # TODO: Add project
    end
  end
end
