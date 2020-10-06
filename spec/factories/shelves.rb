require 'faker'

FactoryBot.define do
  factory :shelf do |s|
    s.name { Faker::Lorem.word }
  end
end