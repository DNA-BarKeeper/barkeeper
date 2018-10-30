# frozen_string_literal: true

json.array!(@higher_order_taxons) do |higher_order_taxon|
  json.extract! higher_order_taxon, :id, :name
  json.url higher_order_taxon_url(higher_order_taxon, format: :json)
end
