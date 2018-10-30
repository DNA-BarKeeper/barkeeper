# frozen_string_literal: true

json.array!(@shelves) do |shelf|
  json.extract! shelf, :id, :name
  json.url shelf_url(shelf, format: :json)
end
