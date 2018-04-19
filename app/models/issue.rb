class Issue < ApplicationRecord
  include ProjectModule

  belongs_to :contig
  belongs_to :primer_read
  has_and_belongs_to_many :projects, -> { distinct }
end
