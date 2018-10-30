# frozen_string_literal: true

json.array!(@markers) do |marker|
  json.extract! marker, :id, :name, :sequence, :accession
  json.url marker_url(marker, format: :json)
end
