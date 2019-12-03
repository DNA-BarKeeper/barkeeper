require 'rails_helper'

RSpec.describe Herbarium do
  subject { FactoryBot.create(:herbarium) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without an acronym" do
    should validate_presence_of(:acronym)
  end

  it "validates the uniqueness of acronym" do
    should validate_uniqueness_of(:acronym)
  end

  it "has many individuals" do
    should have_many(:individuals)
  end
end