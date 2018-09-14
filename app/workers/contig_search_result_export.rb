# frozen_string_literal: true

# Worker that creates an archive of PDE files for the results of an advanced contig search
class ContigSearchResultExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  # Creates an archive of PDE files for all contigs found with the parameters set in +contig_search+
  def perform(contig_search)
    contig_search.create_search_result_archive
  end
end
