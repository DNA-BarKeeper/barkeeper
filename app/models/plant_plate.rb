class PlantPlate < ApplicationRecord
  has_many :isolates
  belongs_to :lab_rack
  validates_presence_of :name
end
