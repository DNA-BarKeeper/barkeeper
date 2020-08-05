require 'faker'

FactoryBot.define do
  factory :tag_primer_map do |t|
    t.name { Faker::Lorem.word }
    t.tag { Faker::Lorem.word }
    t.tag_primer_map { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'tagPrimerMap_2195A.txt')) }
  end
end