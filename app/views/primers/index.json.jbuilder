json.array!(@primers) do |primer|
  json.extract! primer, :id, :name, :sequence, :reverse
  json.url primer_url(primer, format: :json)
end
