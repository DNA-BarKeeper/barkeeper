require 'faker'

FactoryBot.define do
  factory :freezer do |f|
    f.freezercode { Faker::DcComics.hero }
  end
end