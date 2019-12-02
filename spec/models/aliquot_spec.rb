require 'rails_helper'

RSpec.describe Aliquot do
  subject { FactoryBot.create(:aliquot) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one micronic plate" do
    assc = described_class.reflect_on_association(:micronic_plate)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one lab" do
    assc = described_class.reflect_on_association(:lab)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one isolate" do
    assc = described_class.reflect_on_association(:isolate)
    expect(assc.macro).to eq :belongs_to
  end
end