class Lab < ApplicationRecord
  include ProjectRecord

  has_many :users
  has_many :freezers

  validates_presence_of :labcode
end
