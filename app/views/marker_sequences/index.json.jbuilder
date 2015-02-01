json.array!(@marker_sequences) do |marker_sequence|
  json.extract! marker_sequence, :id, :name, :sequence
  json.url marker_sequence_url(marker_sequence, format: :json)
end
