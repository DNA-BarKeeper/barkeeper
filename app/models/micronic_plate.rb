class MicronicPlate < ApplicationRecord
  include ProjectRecord

  has_many :isolates
  belongs_to :lab_rack
end
