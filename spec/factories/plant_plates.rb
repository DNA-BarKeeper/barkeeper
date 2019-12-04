require 'faker'

FactoryBot.define do
  factory :plant_plate do |p|
    p.how_many { Faker::Number.digit }
    p.location_in_rack { Faker::Lorem.word }
    p.name { Faker::Lorem.word }
  end
end