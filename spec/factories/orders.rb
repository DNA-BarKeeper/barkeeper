require 'faker'

FactoryBot.define do
  factory :order do |o|
    o.author { Faker::Science.scientist }
    o.name { Faker::Food.vegetables }

    factory :order_with_taxonomy do
      association :higher_order_taxon, factory: :higher_order_taxon
    end
  end
end