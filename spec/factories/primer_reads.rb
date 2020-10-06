require 'faker'
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :primer_read do |p|
    p.comment { Faker::Lorem.sentence }
    p.name { "GBoL1000_cp148" }
    p.position { Faker::Number.within(range: 1..200) }
    p.window_size { Faker::Number.within(range: 1..20) }
    p.chromatogram { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'GBoL1000_cp148.scf')) }
  end
end