# frozen_string_literal: true

class LabRack < ApplicationRecord
  include ProjectRecord

  belongs_to :freezer
  has_many :plant_plates
  has_many :micronic_plates
end
