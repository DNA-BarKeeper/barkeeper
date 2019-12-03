require 'faker'

FactoryBot.define do
  factory :family do |f|
    f.author { Faker::Science.scientist }
    f.name { Faker::Food.vegetables }
  end
end