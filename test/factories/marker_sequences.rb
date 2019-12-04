require 'faker'

FactoryBot.define do
  factory :marker_sequence do |m|
    m.sequence(:sequence) { Faker::Lorem.characters(number: 500, min_alpha: 500) } # Sequence is a reserved word attribute
    m.genbank { Faker::Lorem.word }
    m.name { Faker::Lorem.word }
    m.reference { Faker::Lorem.word }
  end
end
