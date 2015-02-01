# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :primer_read do
    name "MyString"
    sequence "MyText"
    pherogram_url "MyString"
  end
end
