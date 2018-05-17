class ContigSearchResultExport
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(contig_search)
    contig_search.create_search_result_archive
  end
end