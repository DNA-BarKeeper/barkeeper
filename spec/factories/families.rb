require 'faker'

FactoryBot.define do
  factory :family do |f|
    f.author { Faker::Science.scientist }
    f.name { Faker::Food.vegetables }

    factory :family_with_taxonomy do
      association :order, factory: :order_with_taxonomy
    end
  end
end