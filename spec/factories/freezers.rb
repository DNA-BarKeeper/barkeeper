require 'faker'

FactoryBot.define do
  factory :freezer, class: Freezer do |f|
    f.freezercode { Faker::DcComics.hero }
  end
end