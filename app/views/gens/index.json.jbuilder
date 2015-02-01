json.array!(@gens) do |gen|
  json.extract! gen, :id, :name, :author
  json.url gen_url(gen, format: :json)
end
