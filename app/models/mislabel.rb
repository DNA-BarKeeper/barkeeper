class Mislabel < ApplicationRecord
  belongs_to :mislabel_analysis
  belongs_to :marker_sequence
end
