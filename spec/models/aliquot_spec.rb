require 'rails_helper'

RSpec.describe Aliquot do
  subject { FactoryBot.create(:aliquot) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one micronic plate" do
    should belong_to(:micronic_plate)
  end

  it "has one lab" do
    should belong_to(:lab)
  end

  it "has one isolate" do
    should belong_to(:isolate)
  end
end