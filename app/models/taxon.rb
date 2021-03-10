class Taxon < ApplicationRecord
  include ProjectRecord

  has_ancestry

  validates_presence_of :taxonomic_rank
  validates_presence_of :scientific_name
  validates_uniqueness_of :scientific_name

  enum taxonomic_rank: %i[is_unranked is_division is_subdivision is_class is_order is_family is_genus is_species is_subspecies]
end
