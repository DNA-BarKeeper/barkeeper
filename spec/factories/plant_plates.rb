require 'faker'

FactoryBot.define do
  factory :plant_plate do |p|
    p.name { Faker::Lorem.word }
  end
end