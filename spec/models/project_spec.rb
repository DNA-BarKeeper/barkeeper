require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Project do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:project) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has many contig searches" do
    should have_many(:contig_searches)
  end

  it "has many individual searches" do
    should have_many(:individual_searches)
  end

  it "has many marker sequence searches" do
    should have_many(:marker_sequence_searches)
  end

  it "has and belongs to many users" do
    should have_and_belong_to_many(:users)
  end

  it "has and belongs to many primers" do
    should have_and_belong_to_many(:primers)
  end

  it "has and belongs to many markers" do
    should have_and_belong_to_many(:markers)
  end

  it "has and belongs to many issues" do
    should have_and_belong_to_many(:issues)
  end

  context "class and instance methods" do
    xit "does some stuff" do
    end
  end
end