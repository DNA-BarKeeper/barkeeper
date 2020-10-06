require 'faker'

FactoryBot.define do
  factory :issue do |i|
    i.description { Faker::Lorem.sentence }
    i.title { Faker::Lorem.word }
  end
end
