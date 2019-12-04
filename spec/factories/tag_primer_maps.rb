require 'faker'

FactoryBot.define do
  factory :tag_primer_map do |t|
    t.name { Faker::Lorem.word }
    t.tag { Faker::Lorem.word }
  end
end