class Cluster < ApplicationRecord
  include ProjectRecord

  belongs_to :isolate
  belongs_to :ngs_run
  belongs_to :marker

  has_one :blast_hit, dependent: :destroy

  def isolate_name
    isolate.try(:lab_isolation_nr)
  end
end
