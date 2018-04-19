class LabRack < ApplicationRecord
  include ProjectModule

  belongs_to :freezer
  has_many :plant_plates
  has_many :micronic_plates
  has_and_belongs_to_many :projects, -> { distinct }
end
