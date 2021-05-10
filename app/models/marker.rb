# frozen_string_literal: true

class Marker < ApplicationRecord
  include ProjectRecord

  has_many :marker_sequences
  has_many :contigs
  has_many :clusters
  has_many :ngs_results
  has_many :primers
  has_many :mislabel_analyses

  validates_presence_of :name

  scope :gbol_marker, -> { in_project(Project.find_by_name('GBOL5')) }
end
