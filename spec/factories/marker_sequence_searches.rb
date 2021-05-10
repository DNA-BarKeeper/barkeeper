require 'faker'

FactoryBot.define do
  factory :marker_sequence_search do |ms|
    ms.has_taxon { Faker::Boolean.boolean }
    ms.has_warnings { Faker::Number.between(from: 0, to: 2) }
    ms.marker { Faker::Lorem.word }    
    ms.max_age { Faker::Time.backward(days: 176) }
    ms.max_length { Faker::Number.between(from: 2500, to: 5000) }
    ms.max_update { Faker::Time.backward(days: 176) }
    ms.min_age { Faker::Time.backward(days: 1) }
    ms.min_length { Faker::Number.between(from: 0, to: 2500) }
    ms.min_update { Faker::Time.backward(days: 1) }
    ms.name { Faker::Lorem.word }
    ms.no_isolate { Faker::Boolean.boolean }
    ms.taxon { Faker::Lorem.word }
    ms.specimen { Faker::Lorem.word }
    ms.title { Faker::GreekPhilosophers.name }
    ms.verified { ["verified", "unverified", "both"].sample }
    ms.verified_by { Faker::Name.name }
  end
end