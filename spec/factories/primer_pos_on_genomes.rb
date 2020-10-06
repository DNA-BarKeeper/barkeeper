require 'faker'

FactoryBot.define do
  factory :primer_pos_on_genome do |p|
    p.note { Faker::Lorem.paragraph }
    p.position { Faker::Number.within(range: 1..50) }
  end
end