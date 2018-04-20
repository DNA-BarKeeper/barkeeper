class Shelf < ApplicationRecord
  include ProjectRecord

  belongs_to :freezer

  validates_presence_of :name
end
