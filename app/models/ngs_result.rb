class NgsResult < ApplicationRecord
  belongs_to :isolate
  belongs_to :marker
  belongs_to :ngs_run
end
