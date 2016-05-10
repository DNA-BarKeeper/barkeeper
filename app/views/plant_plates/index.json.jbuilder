json.array!(@freezers) do |plant_plate|
  json.extract! plant_plate, :id, :name, :how_many
  json.url plant_plate_url(plant_plate, format: :json)
end
