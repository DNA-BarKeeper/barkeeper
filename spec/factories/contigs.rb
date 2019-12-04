require 'faker'

FactoryBot.define do
  factory :contig do |c|
    c.allowed_mismatch_percent { Faker::Number.within(range: 1..100) }
    c.assembled { Faker::Boolean.boolean }
    c.assembly_tried { Faker::Boolean.boolean }
    c.comment { Faker::Lorem.sentence}
    c.consensus { Faker::Lorem.word }
    c.fas { Faker::Lorem.paragraph }
    c.imported { Faker::Boolean.boolean }
    c.name { Faker::Lorem.word }
    c.overlap_length { Faker::Number.within(range: 1..100)  }
    c.partial_cons_count { Faker::Number.within(range: 1..10) }
    c.verified { Faker::Boolean.boolean }
    c.verified_at { Faker::Time.backward(days: 176) }
    c.verified_by { Faker::Name.name_with_middle }
  end
end