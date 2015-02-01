# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :primer do
    name "MyString"
    sequence "MyString"
    reverse false
  end
end
