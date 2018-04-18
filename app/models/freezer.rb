class Freezer < ApplicationRecord
  extend ProjectModule

  belongs_to :lab
  has_many :lab_racks
  has_many :shelves
  has_and_belongs_to_many :projects

  validates_presence_of :freezercode
end
