class Lab < ActiveRecord::Base
  has_many :users
  has_many :freezers
  validates_presence_of :labcode
end
