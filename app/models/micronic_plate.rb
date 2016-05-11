class MicronicPlate < ActiveRecord::Base
  has_many :isolates
  belongs_to :lab_rack
end
