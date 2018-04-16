class Project < ApplicationRecord
  has_and_belongs_to_many :users

  has_and_belongs_to_many :issues

  has_and_belongs_to_many :primers
  has_and_belongs_to_many :markers

  has_and_belongs_to_many :isolates
  has_and_belongs_to_many :primer_reads
  has_and_belongs_to_many :contigs
  has_and_belongs_to_many :marker_sequences

  has_and_belongs_to_many :individuals
  has_and_belongs_to_many :species
  has_and_belongs_to_many :families
  has_and_belongs_to_many :orders
  has_and_belongs_to_many :higher_order_taxa

  has_and_belongs_to_many :labs
  # Freezers, lab racks and plates are only associated with a project via their lab. Change if needed.
  has_many :freezers, through: :labs
  has_many :lab_racks, through: :freezers
  has_many :micronic_plates, through: :lab_racks
  has_many :plant_plates, through: :lab_racks

  validates_presence_of :name
end
