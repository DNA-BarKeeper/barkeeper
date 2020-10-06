require 'faker'

FactoryBot.define do
  factory :subdivision do |s|
    s.german_name { Faker::Lorem.word }
    s.name { Faker::Lorem.word }
    s.position { Faker::Number.digit }
  end
end