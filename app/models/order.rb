# frozen_string_literal: true

class Order < ApplicationRecord
  include ProjectRecord
  include PgSearch::Model

  multisearchable against: :name

  has_many :families
  has_many :species, through: :families
  belongs_to :higher_order_taxon
  belongs_to :taxonomic_class

  validates_presence_of :name

  def self.in_higher_order_taxon(higher_order_taxon_id)
    HigherOrderTaxon.find(higher_order_taxon_id).orders.count
  end
end
