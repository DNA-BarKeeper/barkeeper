# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :marker do
    name "MyString"
    sequence "MyText"
    accession "MyString"
  end
end
