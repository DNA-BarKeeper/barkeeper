class Issue < ApplicationRecord
  include ProjectRecord

  belongs_to :contig
  belongs_to :primer_read
end
