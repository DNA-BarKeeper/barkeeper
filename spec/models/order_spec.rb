require 'rails_helper'

RSpec.describe Order do
  subject { FactoryBot.create(:order) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    subject.name = nil
    should_not be_valid
  end

  it "has one higher order taxon" do
    assc = described_class.reflect_on_association(:higher_order_taxon)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one taxonomic class" do
    assc = described_class.reflect_on_association(:taxonomic_class)
    expect(assc.macro).to eq :belongs_to
  end

  it "has many families" do
    assc = described_class.reflect_on_association(:families)
    expect(assc.macro).to eq :has_many
  end

  it "has many species" do
    assc = described_class.reflect_on_association(:species)
    expect(assc.macro).to eq :has_many
  end

  context "returns number of orders in higher order taxon" do
    before(:each) { @hot = FactoryBot.create(:higher_order_taxon) }

    it "returns correct number of orders in higher order taxon" do
      FactoryBot.create(:order, higher_order_taxon: @hot)
      FactoryBot.create(:order, higher_order_taxon: @hot)
      FactoryBot.create(:order, higher_order_taxon: @hot)

      expect(Order.in_higher_order_taxon(@hot.id)).to be == 3
    end

    it "returns correct number for no orders in higher order taxon" do
      expect(Order.in_higher_order_taxon(@hot.id)).to be == 0
    end
  end
end