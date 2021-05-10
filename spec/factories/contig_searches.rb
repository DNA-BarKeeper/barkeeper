require 'faker'
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :contig_search do |cs|
    cs.assembled { ["assembled", "unassembled", "both"].sample }
    cs.has_warnings { ContigSearch.has_warnings.keys.sample }
    cs.marker { Faker::Lorem.word }
    cs.max_age { Faker::Time.backward(days: 176) }
    cs.max_update { Faker::Time.backward(days: 176) }
    cs.min_age { Faker::Time.backward(days: 1) }
    cs.min_update { Faker::Time.backward(days: 1) }
    cs.name { Faker::Lorem.word }
    cs.taxon { Faker::Lorem.word }
    cs.specimen { Faker::Lorem.word }
    cs.title { Faker::Lorem.word }
    cs.verified { ["verified", "unverified", "both"].sample }
    cs.verified_by { Faker::Name.name }

    factory :contig_search_valid_attachment do
      after(:create) do
        attachment = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'search_results.zip'), 'application/zip')
        create(:contig_search, search_result_archive: attachment)
      end
    end
  end
end