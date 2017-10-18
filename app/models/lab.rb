class Lab < ApplicationRecord
  has_many :users
  has_many :freezers
  has_and_belongs_to_many :projects

  validates_presence_of :labcode
end
