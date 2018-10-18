class Family < ApplicationRecord
  include ProjectRecord
  include PgSearch

  multisearchable :against => :name

  has_many :species
  belongs_to :order

  validates_presence_of :name

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count = 0

    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      count += ord.families.count
    end

    count
  end
end
