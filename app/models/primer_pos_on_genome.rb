class PrimerPosOnGenome < ApplicationRecord
  belongs_to :primer
  belongs_to :species
  validates_presence_of :position
end
