# frozen_string_literal: true

# Worker that finds and assembles a given contig
class ContigAssembly
  include Sidekiq::Worker

  # Finds and assembles the contig with the id +c_id+
  def perform(c_id)
    c = Contig.find(c_id)
    c.auto_overlap
  end
end
