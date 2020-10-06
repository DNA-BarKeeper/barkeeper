require 'faker'

FactoryBot.define do
  factory :micronic_plate do |m|
    m.location_in_rack { Faker::Lorem.word }
    m.micronic_plate_id { Faker::Lorem.word }
    m.name { Faker::Lorem.word }
  end
end