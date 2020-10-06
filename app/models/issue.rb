# frozen_string_literal: true

class Issue < ApplicationRecord
  include ProjectRecord

  belongs_to :contig
  belongs_to :primer_read
  belongs_to :ngs_run
end
