# frozen_string_literal: true

class PlantPlate < ApplicationRecord
  include ProjectRecord

  has_many :isolates
  belongs_to :lab_rack

  validates_presence_of :name
end
