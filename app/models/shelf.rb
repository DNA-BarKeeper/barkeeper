class Shelf < ApplicationRecord
  belongs_to :freezer

  validates_presence_of :name
end
