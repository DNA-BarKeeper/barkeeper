class Aliquot < ApplicationRecord
  belongs_to :micronic_plate
  belongs_to :lab
  belongs_to :isolate
end
