# frozen_string_literal: true

json.array!(@individuals) do |individual|
  json.extract! individual, :id, :specimen_id, :DNA_bank_id, :collector
  json.url individual_url(individual, format: :json)
end
