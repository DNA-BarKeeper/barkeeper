require 'faker'

FactoryBot.define do
  factory :tissue do |t|
    t.name { Faker::Lorem.word }
  end
end