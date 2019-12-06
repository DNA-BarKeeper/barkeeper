require 'faker'

FactoryBot.define do
  factory :isolate do |i|
    i.dna_bank_id { Faker::Lorem.word }
    i.lab_isolation_nr { Faker::Lorem.word }
    i.isolation_date { Faker::Time.backward(days: 176) }
    i.negative_control { Faker::Boolean.boolean }
    i.well_pos_plant_plate { Faker::Lorem.word }
  end
end