require 'faker'

FactoryBot.define do
  factory :isolate do |i|
    i.dna_bank_id { Faker::Lorem.word }
    i.lab_isolation_nr { Faker::Lorem.word }
    i.isolation_date { Faker::Time.backward(days: 176) }
    i.negative_control { Faker::Boolean.boolean }
    i.well_pos_plant_plate { Faker::Lorem.word }

    factory :isolate_with_contigs do
      transient do
        contig_count { 4 }
      end

      after(:create) do |isolate, evaluator|
        create_list(:contig, evaluator.contig_count, isolate: isolate)
      end
    end
  end
end