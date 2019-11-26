# frozen_string_literal: true

json.array!(@isolates) do |copy|
  json.extract! copy, :id, :well_pos_plant_plate, :lab_isolation_nr, :micronic_tube_id, :well_pos_micronic_plate, :concentration
  json.url copy_url(copy, format: :json)
end
