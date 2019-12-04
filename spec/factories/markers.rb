require 'faker'

FactoryBot.define do
  factory :marker do |m|
    m.alt_name { Faker::Lorem.word }
    m.expected_reads { Faker::Number.number(digits: 2) }
    m.name { Faker::Lorem.word }
  end
end