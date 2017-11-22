class Subdivision < ApplicationRecord
  has_many :taxonomic_classes
  belongs_to :division
end
