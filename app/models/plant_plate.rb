class PlantPlate < ApplicationRecord
  include ProjectModule

  has_many :isolates
  belongs_to :lab_rack
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :name
end
