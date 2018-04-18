class Individual < ApplicationRecord
  extend ProjectModule
  include PgSearch

  has_many :isolates
  belongs_to :species
  has_and_belongs_to_many :projects

  pg_search_scope :quick_search, against: [:specimen_id, :herbarium, :collector , :collection_nr]

  scope :without_species, -> { where(:species => nil) }
  scope :without_isolates, -> { left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :no_species_isolates, -> { without_species.left_outer_joins(:isolates).select(:id).group(:id).having('count(isolates.id) = 0') }
  scope :bad_location, -> { where('individuals.longitude_original NOT SIMILAR TO ?', '[0-9]{1,}\.{0,}[0-9]{0,}')}

  def self.to_csv(options = {})
    # Change to_csv block to list attributes/values individually
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |individual|
        csv << individual.attributes.values_at(*column_names)
      end
    end
  end

  def self.spp_in_higher_order_taxon(higher_order_taxon_id)
    individuals = Individual.select("species_id").joins(:species => {:family => {:order => :higher_order_taxon}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    individuals_s = Individual.select("species_component").joins(:species => {:family => {:order => :higher_order_taxon}}).where(orders: {higher_order_taxon_id: higher_order_taxon_id})
    [individuals.count, individuals_s.distinct.count, individuals.distinct.count]
  end

  def species_name
    species.try(:composed_name)
  end

  def species_name=(name)
    if name == ''
      self.species = nil
    else
      self.species = Species.find_or_create_by(:composed_name => name) if name.present?
    end
  end

  def habitat_for_display
    if self.habitat.present? and self.habitat.length > 60
      "#{self.habitat[0..30]...self.habitat[-30..-1]}"
    else
      self.habitat
    end
  end

  def locality_for_display
    if self.locality.present? and self.locality.length > 60
      "#{self.locality[0..30]...self.locality[-30..-1]}"
    else
      self.locality
    end
  end

  def comments_for_display
    if self.comments.present? and self.comments.length > 60
      "#{self.comments[0..30]...self.comments[-30..-1]}"
    else
      self.comments
    end
  end
end
