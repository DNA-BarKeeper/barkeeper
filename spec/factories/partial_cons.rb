require 'faker'
require Rails.root.join "spec/support/integer_array_helper.rb"

FactoryBot.define do
  factory :partial_con do |p|
    p.aligned_qualities { integer_array(150) }
    p.aligned_sequence { Faker::Lorem.characters(number: 150, min_alpha: 150) }
    p.sequence(:sequence) { Faker::Lorem.characters(number: 150, min_alpha: 150) } # Sequence is a reserved word attribute
  end
end