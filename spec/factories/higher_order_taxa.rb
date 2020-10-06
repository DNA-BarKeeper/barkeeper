require 'faker'

FactoryBot.define do
  factory :higher_order_taxon do |hot|
    hot.german_name { Faker::Lorem.word }
    hot.name { Faker::Lorem.word }
    hot.position { Faker::Number.digit }
  end
end