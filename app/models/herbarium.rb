class Herbarium < ApplicationRecord
  validates_presence_of :acronym
  validates :acronym, uniqueness: true

  has_many :individuals
end
