require 'faker'

FactoryBot.define do
  factory :herbarium do |h|
    h.name { Faker::Lorem.word }
    h.acronym { Faker::Hacker.abbreviation }
  end
end