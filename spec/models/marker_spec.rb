require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Marker do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:marker) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has and belongs to many higher order taxa" do
    should have_and_belong_to_many(:higher_order_taxa)
  end

  it "have many marker sequences" do
    should have_many(:marker_sequences)
  end

  it "have many mislabel_analyses" do
    should have_many(:mislabel_analyses)
  end

  it "have many contigs" do
    should have_many(:contigs)
  end

  it "have many clusters" do
    should have_many(:clusters)
  end

  it "have many ngs results" do
    should have_many(:ngs_results)
  end

  it "have many primers" do
    should have_many(:primers)
  end
end