class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :newses
  validates_presence_of :name
end
