require 'faker'

FactoryBot.define do
  factory :blast_hit do |b|
    b.e_value { Faker::Number.decimal }
    b.taxonomy { Faker::Lorem.sentence }
  end
end