class Shelf < ActiveRecord::Base
  belongs_to :freezer
  validates_presence_of :name
end
