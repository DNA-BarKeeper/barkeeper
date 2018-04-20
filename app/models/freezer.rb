class Freezer < ApplicationRecord
  include ProjectRecord

  belongs_to :lab
  has_many :lab_racks
  has_many :shelves

  validates_presence_of :freezercode
end
