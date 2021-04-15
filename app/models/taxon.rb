class Taxon < ApplicationRecord
  include ProjectRecord

  has_many :individuals
  has_many :ngs_runs

  has_ancestry  cache_depth: true, counter_cache: true

  validates_presence_of :scientific_name
  validates_uniqueness_of :scientific_name
  validates_presence_of :taxonomic_rank

  after_save :update_descendants_counter_cache
  after_destroy :update_descendants_counter_cache

  enum taxonomic_rank: %i[is_unranked is_division is_subdivision is_class is_order is_family is_genus is_species is_subspecies]

  def self.subtree_json(parent_id=nil)
    if parent_id
      Taxon.find(parent_id).children.order(:position, :scientific_name).arrange_serializable do |parent, children|
        { id: parent.id,
          scientific_name: parent.scientific_name,
          has_children: parent.children_count.positive?,
          children: children}
      end.to_json
    else
      Taxon.roots.where(taxonomic_rank: :is_unranked).first.subtree.to_depth(1).order(:position, :scientific_name).arrange_serializable do |parent, children|
        { id: parent.id,
          scientific_name: parent.scientific_name,
          has_children: parent.children_count.positive?,
          children: children}
      end.to_json
    end
  end

  def self.find_by_sci_name_or_synonym(identifier)
    taxon = Taxon.find_by_scientific_name(identifier)
    taxon ||= Taxon.find_by_synonym(identifier)
    taxon
  end

  def self.find_or_create_by_sci_name_or_synonym(identifier, **attributes)
    taxon = Taxon.find_by_sci_name_or_synonym(identifier)
    taxon ||= Taxon.create(scientific_name: identifier, attributes: attributes)
    taxon
  end

  def update_descendants_counter_cache
    self.update_column(:descendants_count, self.descendants.where(taxonomic_rank: [:is_species, :is_subspecies]).size)
  end

  def parent_name
    parent.try(:scientific_name)
  end

  def parent_name=(scientific_name)
    if scientific_name == ''
      self.parent = nil
    else
      self.parent = Taxon.find_by(scientific_name: scientific_name) if scientific_name.present?
    end
  end
end
