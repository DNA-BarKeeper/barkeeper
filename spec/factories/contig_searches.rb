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
    cs.search_result_archive { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'search_results.zip'), 'application/zip') }

    factory :contig_search_incorrect_file_ending, parent: :contig_search do
      search_result_archive { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'search_results.txt'), 'application/zip') }
    end

    factory :contig_search_text_file, parent: :contig_search do
      search_result_archive { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'text_file.txt')) }
    end
  end
end