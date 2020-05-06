require 'faker'

FactoryBot.define do
  factory :primer_read do |p|
    # p.aligned_peak_indices { integer_array(200) }
    # p.aligned_qualities { integer_array(200) }
    # p.aligned_seq { Faker::Lorem.characters(number: 200, min_alpha: 200) }
    p.assembled { Faker::Boolean.boolean }
    # p.atrace { integer_array(200) }
    # p.base_count { Faker::Number.within(range: 1..200) }
    p.comment { Faker::Lorem.sentence }
    # p.count_in_window { Faker::Number.within(range: 1..20) }
    # p.ctrace { integer_array(200) }
    # p.gtrace { integer_array(200) }
    # p.min_quality_score { Faker::Number.within(range: 1..10) }
    p.name { Faker::Lorem.word }
    # p.overwritten { Faker::Boolean.boolean }
    # p.peak_indices { integer_array(200) }
    # p.pherogram_url { Faker::Internet.url }
    p.position { Faker::Number.within(range: 1..200) }
    # p.processed { Faker::Boolean.boolean }
    # p.qualities { integer_array(200) }
    # p.quality_string { integer_array(200).join }
    # p.reverse { Faker::Boolean.boolean }
    # p.sequence(:sequence) { Faker::Lorem.characters(number: 200, min_alpha: 200) } # Sequence is a reserved word attribute
    # p.trimmedReadEnd { Faker::Number.within(range: 1..200) }
    # p.trimmedReadStart { Faker::Number.within(range: 1..200) }
    # p.ttrace { integer_array(200) }
    p.used_for_con { Faker::Boolean.boolean }
    p.window_size { Faker::Number.within(range: 1..20) }
  end
end