json.array!(@alignments) do |alignment|
  json.extract! alignment, :id, :name, :URL
  json.url alignment_url(alignment, format: :json)
end
