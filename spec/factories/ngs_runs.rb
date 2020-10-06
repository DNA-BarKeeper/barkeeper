require 'faker'

FactoryBot.define do
  factory :ngs_run do |n|
    n.comment { Faker::Lorem.sentence }
    n.fastq_location { Faker::Lorem.word }
    n.name { Faker::Lorem.word }
    n.primer_mismatches { Faker::Number.within(range: 1..10) }
    n.quality_threshold { Faker::Number.within(range: 1..100) }
    n.sequences_filtered { Faker::Number.within(range: 1..100) }
    n.sequences_high_qual { Faker::Number.within(range: 1..100) }
    n.sequences_one_primer { Faker::Number.within(range: 1..100) }
    n.sequences_pre { Faker::Number.within(range: 1..100) }
    n.sequences_short { Faker::Number.within(range: 1..100) }
    n.tag_mismatches { Faker::Number.within(range: 1..10) }
  end
end