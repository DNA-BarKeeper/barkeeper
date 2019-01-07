# frozen_string_literal: true

json.array!(@orders) do |order|
  json.extract! order, :id, :name, :author
  json.url order_url(order, format: :json)
end
