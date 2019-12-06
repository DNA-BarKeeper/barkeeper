require 'faker'
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :contig_search do |cs|
    cs.assembled { ["assembled", "unassembled", "both"].sample }
    cs.family { Faker::Lorem.word }
    cs.has_warnings { ContigSearch.has_warnings.keys.sample }
    cs.marker { Faker::Lorem.word }
    cs.max_age { Faker::Time.backward(days: 176) }
    cs.max_update { Faker::Time.backward(days: 176) }
    cs.min_age { Faker::Time.backward(days: 1) }
    cs.min_update { Faker::Time.backward(days: 1) }
    cs.name { Faker::Lorem.word }
    cs.order { Faker::Lorem.word }
    cs.species { Faker::Lorem.word }
    cs.specimen { Faker::Lorem.word }
    cs.title { Faker::Lorem.word }
    cs.verified { ["verified", "unverified", "both"].sample }
    cs.verified_by { Faker::Name.name }
    cs.search_result_archive { fixture_file_upload("#{Rails.root}/spec/support/fixtures/search_results.zip", 'application/zip') }
  end
end