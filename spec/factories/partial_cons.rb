# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :partial_con do
    sequence "MyString"
    aligned_sequence "MyString"
  end
end
