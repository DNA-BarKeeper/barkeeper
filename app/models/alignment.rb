class Alignment < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :URL
end
