# frozen_string_literal: true

json.array!(@issues) do |issue|
  json.extract! issue, :id, :title, :description
  json.url issue_url(issue, format: :json)
end
