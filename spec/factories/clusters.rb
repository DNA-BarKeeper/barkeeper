require 'faker'

FactoryBot.define do
  factory :cluster do |c|
    c.centroid_sequence { Faker::Lorem.word }
    c.fasta { Faker::Lorem.paragraph(sentence_count: 15) }
    c.name { Faker::Lorem.word }
    c.reverse_complement { Faker::Boolean.boolean }
    c.running_number { Faker::Number.number(digits: 2) }
    c.sequence_count { Faker::Number.number(digits: 3) }
  end
end