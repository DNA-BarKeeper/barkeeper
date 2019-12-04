require 'faker'

FactoryBot.define do
  factory :user do |u|
    u.default_project_id { 1 }
    u.email { Faker::Internet.email }
    u.name { Faker::Name.name }
    u.role { Faker::Number.between(from: 0, to: 3) }
  end
end