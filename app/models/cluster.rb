class Cluster < ApplicationRecord
  belongs_to :isolate
  belongs_to :ngs_run
  belongs_to :marker

  def isolate_name
    isolate.try(:lab_nr)
  end
end
