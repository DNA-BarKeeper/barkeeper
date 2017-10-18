class TaxonomicClass < ApplicationRecord
  belongs_to :subdivision
  has_many :orders
end
