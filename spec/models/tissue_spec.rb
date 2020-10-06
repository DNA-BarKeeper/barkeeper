require 'rails_helper'

RSpec.describe Tissue do
  subject { FactoryBot.create(:tissue) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has many isolates" do
    should have_many(:isolates)
  end

  it "has many individuals" do
    should have_many(:individuals)
  end
end