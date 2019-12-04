require 'faker'

FactoryBot.define do
  factory :mislabel_analysis do |m|
    m.automatic { Faker::Boolean.boolean }
    m.title { Faker::Lorem.word }
    m.total_seq_number { Faker::Number.within(range: 0..2000) }
  end
end