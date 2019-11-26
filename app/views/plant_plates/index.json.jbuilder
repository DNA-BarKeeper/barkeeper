# frozen_string_literal: true

json.array!(@plant_plates) do |plant_plate|
  json.extract! plant_plate, :id, :name, :how_many
  json.url plant_plate_url(plant_plate, format: :json)
end
