# frozen_string_literal: true

json.array!(@families) do |family|
  json.extract! family, :id, :name, :author
  json.url family_url(family, format: :json)
end
