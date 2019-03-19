class Cluster < ApplicationRecord
  belongs_to :isolate
  belongs_to :ngs_run
  belongs_to :marker

  has_one :blast_hit, dependent: :destroy

  def isolate_name
    isolate.try(:lab_nr)
  end
end
