class Marker < ActiveRecord::Base
  has_many :marker_sequences
  has_many :contigs
  has_many :primers
  validates_presence_of :name

  scope :gbol_marker, -> { where(:is_gbol => true)}
end
