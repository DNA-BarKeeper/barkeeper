class Shelf < ApplicationRecord
  extend ProjectModule

  belongs_to :freezer
  has_and_belongs_to_many :projects

  validates_presence_of :name
end
