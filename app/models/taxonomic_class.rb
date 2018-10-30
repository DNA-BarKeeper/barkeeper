# frozen_string_literal: true

class TaxonomicClass < ApplicationRecord
  belongs_to :subdivision
  has_many :orders
end
