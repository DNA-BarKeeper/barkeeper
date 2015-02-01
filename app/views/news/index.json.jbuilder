json.array!(@news) do |news|
  json.extract! news, :id, :title, :body, :published
  json.url news_url(news, format: :json)
end
