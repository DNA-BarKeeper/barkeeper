class Family < ActiveRecord::Base
  has_many :species
  belongs_to :order
  validates_presence_of :name
  has_and_belongs_to_many :projects

  def self.in_higher_order_taxon(higher_order_taxon_id)
    count=0

    HigherOrderTaxon.find(higher_order_taxon_id).orders.each do |ord|
      count+=ord.families.count
    end

    count
  end

end
