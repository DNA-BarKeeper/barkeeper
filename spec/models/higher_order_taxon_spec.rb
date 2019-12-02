require 'rails_helper'

RSpec.describe HigherOrderTaxon do
  before(:all) { Project.create(name: 'All') }

  subject { FactoryBot.create(:higher_order_taxon) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    subject.name = nil
    should_not be_valid
  end

  it "has and belongs to many markers" do
    assc = described_class.reflect_on_association(:markers)
    expect(assc.macro).to eq :has_and_belongs_to_many
  end

  it "has many orders" do
    assc = described_class.reflect_on_association(:orders)
    expect(assc.macro).to eq :has_many
  end

  it "has many families" do
    assc = described_class.reflect_on_association(:families)
    expect(assc.macro).to eq :has_many
  end

  it "has many NGS runs" do
    assc = described_class.reflect_on_association(:ngs_runs)
    expect(assc.macro).to eq :has_many
  end
end