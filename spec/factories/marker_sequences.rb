require 'faker'

FactoryBot.define do
  factory :marker_sequence do |m|
    m.sequence(:sequence) { Faker::Lorem.characters(number: 500, min_alpha: 500) } # Sequence is a reserved word attribute
    m.genbank { Faker::Lorem.word }
    m.name { Faker::Lorem.word }
    m.reference { Faker::Lorem.word }

    factory :marker_sequence_with_taxonomy do
      association :isolate, factory: :isolate_with_taxonomy
      association :marker, factory: :marker
    end
  end
end
