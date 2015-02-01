json.array!(@labs) do |lab|
  json.extract! lab, :id, :labcode
  json.url lab_url(lab, format: :json)
end
