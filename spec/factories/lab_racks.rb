require 'faker'

FactoryBot.define do
  factory :lab_rack do |lr|
    lr.rack_position { Faker::Lorem.word }
    lr.rackcode { Faker::Lorem.word }
    lr.shelf { Faker::Lorem.word }
  end
end