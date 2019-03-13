class Cluster < ApplicationRecord
  belongs_to :isolate
  belongs_to :ngs_run
  belongs_to :marker
end
