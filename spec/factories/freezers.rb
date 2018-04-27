require 'faker'

FactoryBot.define do
  factory :freezer do |f|
    f.freezercode { Faker::Types.string }
  end
end