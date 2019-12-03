require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Order do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:order) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has one higher order taxon" do
    should belong_to(:higher_order_taxon)
  end

  it "has one taxonomic class" do
    should belong_to(:taxonomic_class)
  end

  it "has many families" do
    should have_many(:families)
  end

  it "has many species" do
    should have_many(:species)
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