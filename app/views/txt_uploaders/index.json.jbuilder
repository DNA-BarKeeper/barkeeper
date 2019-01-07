# frozen_string_literal: true

json.array!(@txt_uploaders) do |txt_uploader|
  json.extract! txt_uploader, :id
  json.url txt_uploader_url(txt_uploader, format: :json)
end
