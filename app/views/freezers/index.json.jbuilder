json.array!(@freezers) do |freezer|
  json.extract! freezer, :id, :freezercode
  json.url freezer_url(freezer, format: :json)
end
