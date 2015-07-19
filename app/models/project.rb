class Project < ActiveRecord::Base

  has_and_belongs_to_many :users
  has_and_belongs_to_many :individuals
  has_and_belongs_to_many :species
  has_and_belongs_to_many :families
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :higher_order_taxa
  has_and_belongs_to_many :isolates
  has_and_belongs_to_many :contigs
  has_and_belongs_to_many :primer_reads
  has_and_belongs_to_many :issues
  has_and_belongs_to_many :labs


  validates_presence_of :name
end
