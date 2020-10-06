require 'rails_helper'

RSpec.describe Division do
  subject { FactoryBot.create(:division) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has many subdivisions" do
    should have_many(:subdivisions)
  end
end