json.array!(@tissues) do |tissue|
  json.extract! tissue, :id, :name
  json.url tissue_url(tissue, format: :json)
end
