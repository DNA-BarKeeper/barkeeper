class HigherOrderTaxon < ActiveRecord::Base
  has_many :orders
  has_many :families, :through => :orders
  validates_presence_of :name
end
