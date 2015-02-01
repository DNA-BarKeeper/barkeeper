json.array!(@species_epithets) do |species_epithet|
  json.extract! species_epithet, :id, :name
  json.url species_epithet_url(species_epithet, format: :json)
end
