require 'faker'

FactoryBot.define do
  factory :user do |u|
    u.default_project_id { 1 }
    u.email { Faker::Internet.email }
    u.name { Faker::Name.name }
    u.role { 'user' }

    factory :admin do
      after(:create) do
        create(:user, role: 'admin')
      end
    end

    factory :guest do
      after(:create) do
        create(:user, role: 'guest')
      end
    end

    factory :supervisor do
      after(:create) do
        create(:user, role: 'supervisor')
      end
    end
  end
end