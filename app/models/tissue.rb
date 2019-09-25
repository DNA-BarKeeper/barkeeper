# frozen_string_literal: true

class Tissue < ApplicationRecord
  has_many :isolates
  has_many :individuals

  validates_presence_of :name
end
