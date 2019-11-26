# frozen_string_literal: true

json.array!(@lab_racks) do |lab_rack|
  json.extract! lab_rack, :id, :rackcode
  json.url lab_rack_url(lab_rack, format: :json)
end
