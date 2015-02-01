# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project do
    name "MyString"
    description "MyText"
    start "2014-05-10 15:50:15"
    due "2014-05-10 15:50:15"
  end
end
