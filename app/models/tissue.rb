class Tissue < ActiveRecord::Base
  has_many :isolates
  validates_presence_of :name
end
