require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe NgsRun do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:ngs_run) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "ensures name is unique" do
    should validate_uniqueness_of(:name)
  end

  it "belongs to a higher order taxon" do
    should belong_to(:higher_order_taxon)
  end

  it "has many tag primer maps" do
    should have_many(:tag_primer_maps)
  end

  it "has many clusters" do
    should have_many(:clusters).dependent(:destroy)
  end

  it "has many ngs results" do
    should have_many(:ngs_results).dependent(:destroy)
  end

  it "has many isolates" do
    should have_many(:isolates).through(:clusters)
  end

  it "has many markers" do
    should have_many(:markers).through(:ngs_results)
  end

  it "parses package map after save" do
    should callback(:parse_package_map).after(:save)
  end

  xit "other methods"
end