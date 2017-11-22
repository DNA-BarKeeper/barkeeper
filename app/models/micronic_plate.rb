class MicronicPlate < ApplicationRecord
  has_many :isolates
  belongs_to :lab_rack
end
