class HigherOrderTaxon < ApplicationRecord
  has_many :orders
  has_many :families, :through => :orders
  has_and_belongs_to_many :markers
  has_and_belongs_to_many :projects

  validates_presence_of :name
end
