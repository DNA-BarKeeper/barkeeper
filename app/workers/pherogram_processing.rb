# frozen_string_literal: true

# Worker that processes uploaded pherograms
class PherogramProcessing
  include Sidekiq::Worker

  sidekiq_options queue: :pherogram_processing

  # Assigns the primer read specified by +primer_read_id+ to an isolate and a
  # primer and then trims it. Processed primer reads get the comment 'imported'.
  def perform(primer_read_id)
    primer_read = PrimerRead.find(primer_read_id)
    begin
      primer_read.auto_assign # Ensures that the read sequence gets reverse-complemented when the primer is reverse oriented
      primer_read.auto_trim(true)
    rescue StandardError
    end
    primer_read.update(processed: true, used_for_con: true, assembled: false, comment: 'imported')
  end
end
