# frozen_string_literal: true

# Worker that imports NGS run results
class AnalyseNGSData
  include Sidekiq::Worker

  def perform(ngs_run_id)
    ngs_run = NgsRun.find(ngs_run_id)
    ngs_run.run_pipe
  end
end