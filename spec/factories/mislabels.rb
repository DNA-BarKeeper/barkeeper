require 'faker'

FactoryBot.define do
  factory :mislabel do |m|
    m.confidence { Faker::Number.decimal(l_digits: 2) }
    m.level { Faker::Lorem.word }
    m.path_confidence { Faker::Lorem.word }
    m.proposed_label { Faker::Lorem.word }
    m.proposed_path { Faker::Lorem.word }
    m.solved { Faker::Boolean.boolean }
    m.solved_at { Faker::Time.backward(days: 176) }
    m.solved_by { Faker::Name.name_with_middle }
  end
end