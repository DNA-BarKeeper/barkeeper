json.array!(@primer_reads) do |primer_read|
  json.extract! primer_read, :id, :name, :sequence, :pherogram_url
  json.url primer_read_url(primer_read, format: :json)
end
