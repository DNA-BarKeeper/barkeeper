class Lab < ApplicationRecord
  include ProjectModule

  has_many :users
  has_many :freezers
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :labcode
end
