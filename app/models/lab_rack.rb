class LabRack < ApplicationRecord
  belongs_to :freezer
  has_many :plant_plates
  has_many :micronic_plates
end
