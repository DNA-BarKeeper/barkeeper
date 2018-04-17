class Freezer < ApplicationRecord
  belongs_to :lab
  has_many :lab_racks
  has_many :shelves
  has_many :projects, through: :lab

  validates_presence_of :freezercode
end
