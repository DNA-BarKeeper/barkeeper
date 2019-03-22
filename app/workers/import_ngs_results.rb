# frozen_string_literal: true

# Worker that imports NGS run results
class NGSResultImporter
  include Sidekiq::Worker

  def perform(ngs_run_id)
    ngs_run = NgsRun.find(ngs_run_id)
    ngs_run.check_results
  end
end