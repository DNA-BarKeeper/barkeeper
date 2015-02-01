json.array!(@micronic_plates) do |micronic_plate|
  json.extract! micronic_plate, :id, :micronic_plate_id, :name
  json.url micronic_plate_url(micronic_plate, format: :json)
end
