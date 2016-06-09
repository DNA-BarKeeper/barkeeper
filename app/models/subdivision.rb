class Subdivision < ActiveRecord::Base
  has_many :taxonomic_classes
  belongs_to :division
end
