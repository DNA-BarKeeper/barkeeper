# frozen_string_literal: true

class Lab < ApplicationRecord
  include ProjectRecord

  has_many :users
  has_many :freezers
  has_many :aliquots

  validates_presence_of :labcode
end
