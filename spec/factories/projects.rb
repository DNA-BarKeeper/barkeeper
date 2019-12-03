require 'faker'

FactoryBot.define do
  factory :project do |p|
    p.description { Faker::Lorem.sentence }
    p.due { Faker::Time.backward(days: 14)  }
    p.name { Faker::Lorem.word }
    p.start { Faker::Time.backward(days: 28)  }
  end
end