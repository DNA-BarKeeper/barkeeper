require 'rails_helper'

RSpec.describe Freezer do
  subject { FactoryBot.create(:freezer) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a freezercode" do
    subject.freezercode = nil
    should_not be_valid
  end

  it "has one lab" do
    assc = described_class.reflect_on_association(:lab)
    expect(assc.macro).to eq :belongs_to
  end

  it "has many lab racks" do
    assc = described_class.reflect_on_association(:lab_racks)
    expect(assc.macro).to eq :has_many
  end

  it "has many shelves" do
    assc = described_class.reflect_on_association(:shelves)
    expect(assc.macro).to eq :has_many
  end
end