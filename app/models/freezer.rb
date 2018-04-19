class Freezer < ApplicationRecord
  include ProjectModule

  belongs_to :lab
  has_many :lab_racks
  has_many :shelves
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :freezercode
end
