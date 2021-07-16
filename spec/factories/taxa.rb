FactoryBot.define do
  factory :taxon do
    scientific_name { "MyString" }
    common_name { "MyString" }
    position { "MyString" }
    synonym { "MyString" }
    author { "MyString" }
    comment { "MyText" }
  end
end
