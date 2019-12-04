require 'faker'

FactoryBot.define do
  factory :responsibility do |r|
    r.description { Faker::Lorem.sentence }
    r.name { Faker::Name.name_with_middle }
  end
end