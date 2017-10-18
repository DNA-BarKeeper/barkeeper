class Tissue < ApplicationRecord
  has_many :isolates
  validates_presence_of :name
end
