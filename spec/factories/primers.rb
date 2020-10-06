require 'faker'

FactoryBot.define do
  factory :primer do |p|
    p.name { Faker::Lorem.word }
    p.alt_name { Faker::Lorem.word }
    p.author { Faker::Name.name }
    p.labcode { Faker::Lorem.characters(number: 6) }
    p.notes { Faker::Lorem.sentence }
    p.position { Faker::Number.within(range: 1..200) }
    p.reverse { Faker::Boolean.boolean }
    p.sequence(:sequence) { Faker::Lorem.characters(number: 25, min_alpha: 25) } # Sequence is a reserved word attribute
    p.target_group { Faker::Lorem.word }
    p.tm { Faker::Lorem.word }

    factory :primer_with_marker do
      association :marker, factory: :marker
    end
  end
end