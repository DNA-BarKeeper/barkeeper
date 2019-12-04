require 'faker'

FactoryBot.define do
  factory :lab do |l|
    l.labcode { Faker::Hacker.abbreviation }
  end
end
