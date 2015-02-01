json.array!(@species) do |species|
  json.extract! species, :id, :author, :genus_name, :species_epithet
  json.url species_url(species, format: :json)
end
