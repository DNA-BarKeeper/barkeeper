class PherogramProcessing

  include Sidekiq::Worker

  def perform(primer_read_id)
    primer_read=PrimerRead.find(primer_read_id)
    primer_read.auto_assign #ensures that gets reverse-complemented when primer is reverse
    primer_read.auto_trim
    primer_read.update(:used_for_con => true, :assembled => false)
  end

end