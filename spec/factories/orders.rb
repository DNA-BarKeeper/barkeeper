require 'faker'

FactoryBot.define do
  factory :order do |o|
    o.author { Faker::Science.scientist }
    o.name { Faker::Food.vegetables }
  end
end