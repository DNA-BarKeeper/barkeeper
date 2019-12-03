require 'faker'

FactoryBot.define do
  factory :division do |d|
    d.name { Faker::Lorem.word }
  end
end