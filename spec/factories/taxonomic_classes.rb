require 'faker'

FactoryBot.define do
  factory :taxonomic_class do |t|
    t.german_name { Faker::Lorem.word }
    t.name { Faker::Lorem.word }
  end
end