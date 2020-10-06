require 'rails_helper'
require Rails.root.join 'spec/concerns/project_record_spec.rb'

RSpec.describe HigherOrderTaxon do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:higher_order_taxon) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has and belongs to many markers" do
    should have_and_belong_to_many(:markers)
  end

  it "has many orders" do
    should have_many(:orders)
  end

  it "has many families" do
    should have_many(:families).through(:orders)
  end

  it "has many NGS runs" do
    should have_many(:ngs_runs)
  end
end