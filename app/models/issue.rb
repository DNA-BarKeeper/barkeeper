class Issue < ActiveRecord::Base
  belongs_to :contig
  belongs_to :primer_read
end
