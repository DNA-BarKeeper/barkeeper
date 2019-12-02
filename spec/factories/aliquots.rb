require 'faker'

FactoryBot.define do
  factory :aliquot do |a|
    a.comment { Faker::Lorem.sentence }
    a.concentration { Faker::Number.decimal(l_digits: 6) }
    a.is_original { Faker::Boolean.boolean }
    a.micronic_tube { Faker::Lorem.word }
    a.well_pos_micronic_plate { Faker::Lorem.word }
  end
end