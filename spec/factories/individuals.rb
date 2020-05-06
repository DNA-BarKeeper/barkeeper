require 'faker'

FactoryBot.define do
  factory :individual do |i|
    i.collected { Faker::Time.backward(days: 176) }
    i.collection_date { Faker::Time.backward(days: 176) }
    i.collector { Faker::Name.name_with_middle }
    i.collectors_field_number { Faker::Lorem.word }
    i.comments { Faker::Lorem.paragraph }
    i.confirmation { Faker::Lorem.word }
    i.country { Faker::Address.country }
    i.determination { Faker::Lorem.word }
    i.DNA_bank_id { Faker::Lorem.word }
    i.elevation { Faker::Lorem.word }
    i.exposition { Faker::Lorem.word }
    i.habitat { Faker::Lorem.sentence }
    i.has_issue { Faker::Boolean.boolean }
    i.herbarium_code { Faker::Lorem.word }
    i.latitude { Faker::Address.latitude }
    i.latitude_original { Faker::Address.latitude.to_s }
    i.longitude { Faker::Address.longitude }
    i.life_form { Faker::Lorem.word }
    i.locality { Faker::Lorem.paragraph }
    i.longitude_original { Faker::Address.longitude.to_s }
    i.revision { Faker::Lorem.word }
    i.silica_gel { Faker::Boolean.boolean }
    i.state_province { Faker::Address.state }
    i.substrate { Faker::Lorem.word }

    factory :individual_with_taxonomy do
      association :species, factory: :species_with_taxonomy
    end

    factory :individual_with_isolates do
      transient do
        isolate_count { 10 }
      end

      after(:create) do |individual, evaluator|
        create_list(:isolate, evaluator.isolate_count, individual: individual)
      end
    end
  end
end