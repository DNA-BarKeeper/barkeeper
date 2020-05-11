class HigherOrderTaxon < ApplicationRecord
  include ProjectRecord
  include PgSearch::Model

  multisearchable :against => :name

  has_ancestry

  has_many :orders
  has_many :families, :through => :orders
  has_many :ngs_runs
  has_and_belongs_to_many :markers

  validates_presence_of :name
end
