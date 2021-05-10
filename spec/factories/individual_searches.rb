require 'faker'

FactoryBot.define do
  factory :individual_search do |is|
    is.DNA_bank_id { Faker::Lorem.word }
    is.has_issue { Faker::Number.between(from: 0, to: 2) }
    is.has_problematic_location { Faker::Number.between(from: 0, to: 2) }
    is.has_taxon { Faker::Number.between(from: 0, to: 2) }
    is.herbarium { Faker::Lorem.word }
    is.taxon { Faker::Lorem.word }
    is.title { Faker::Lorem.word }
  end
end