class MicronicPlate < ApplicationRecord
  extend ProjectModule

  has_many :isolates
  belongs_to :lab_rack
  has_and_belongs_to_many :projects
end
