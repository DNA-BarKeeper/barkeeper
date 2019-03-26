# frozen_string_literal: true

# Worker that imports NGS run results
class NGSResultsImporter
  include Sidekiq::Worker

  def perform(ngs_run_id)
    ngs_run = NgsRun.find(ngs_run_id)
    ngs_run.import
  end
end