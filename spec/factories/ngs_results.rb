require 'faker'

FactoryBot.define do
  factory :ngs_result do |n|
    n.cluster_count { Faker::Number.within(range: 0..2000) }
    n.hq_sequences { Faker::Number.within(range: 0..2000) }
    n.incomplete_sequences { Faker::Number.within(range: 0..2000) }
    n.total_sequences { Faker::Number.within(range: 0..2000) }
  end
end