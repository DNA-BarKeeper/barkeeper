class Issue < ActiveRecord::Base
  belongs_to :contig
  belongs_to :primer_read
  has_and_belongs_to_many :projects

end
