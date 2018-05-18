class HigherOrderTaxon < ApplicationRecord
  include ProjectRecord
  include PgSearch

  multisearchable :against => :name

  has_many :orders
  has_many :families, :through => :orders
  has_and_belongs_to_many :markers

  validates_presence_of :name
end
