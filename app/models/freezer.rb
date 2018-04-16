class Freezer < ApplicationRecord
  belongs_to :lab
  has_many :lab_racks
  has_many :shelves

  validates_presence_of :freezercode
end
