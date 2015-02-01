# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :marker_sequence do
    name "MyString"
    sequence "MyString"
  end
end
