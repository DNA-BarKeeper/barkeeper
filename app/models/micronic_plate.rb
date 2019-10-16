# frozen_string_literal: true

class MicronicPlate < ApplicationRecord
  include ProjectRecord

  has_many :isolates # TODO remove after all values are transferred to aliquots
  has_many :aliquots
  belongs_to :lab_rack
end
