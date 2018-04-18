class PlantPlate < ApplicationRecord
  extend ProjectModule

  has_many :isolates
  belongs_to :lab_rack
  has_and_belongs_to_many :projects

  validates_presence_of :name
end
