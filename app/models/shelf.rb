class Shelf < ApplicationRecord
  include ProjectModule

  belongs_to :freezer
  has_and_belongs_to_many :projects, -> { distinct }

  validates_presence_of :name
end
