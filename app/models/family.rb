class Family < ApplicationRecord
  extend ProjectModule

  has_many :species
  belongs_to :order
  has_and_belongs_to_many :projects

  validates_presence_of :name

  # Returns the number of species for which at least one marker sequence for this marker exists
  def completed_species_cnt(marker_id)
    cnt = 0
    self.species.each do |s|
      has_ms = false
      s.individuals.each do |i|
        i.isolates.each do |iso|
          has_ms = iso.marker_sequences.where(:marker_id => marker_id).any? ? true : has_ms
        end
      end
      cnt += 1 if has_ms
    end
    cnt
  end

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count = 0

    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      count += ord.families.count
    end

    count
  end

end
