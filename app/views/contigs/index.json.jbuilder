# frozen_string_literal: true

json.array!(@contigs) do |contig|
  json.extract! contig, :id, :name, :consensus
  json.url contig_url(contig, format: :json)
end
