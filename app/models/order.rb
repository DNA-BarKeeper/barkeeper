class Order < ApplicationRecord
  has_many :families
  has_many :species, :through => :families
  belongs_to :higher_order_taxon
  belongs_to :taxonomic_class
  has_and_belongs_to_many :projects

  validates_presence_of :name

  def self.in_higher_order_taxon(higher_order_taxon_id)
    HigherOrderTaxon.find(higher_order_taxon_id).orders.count
  end
end
