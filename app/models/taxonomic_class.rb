class TaxonomicClass < ActiveRecord::Base
  belongs_to :subdivision
  has_many :orders
end
