require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Lab do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:lab) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a labcode" do
    should validate_presence_of(:labcode)
  end

  it "has many users" do
    should have_many(:users)
  end

  it "has many freezers" do
    should have_many(:freezers)
  end

  it "has many aliquots" do
    should have_many(:aliquots)
  end
end