require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Freezer do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:freezer) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a freezercode" do
    should validate_presence_of(:freezercode)
  end

  it "has one lab" do
    should belong_to(:lab)
  end

  it "has many lab racks" do
    should have_many(:lab_racks)
  end

  it "has many shelves" do
    should have_many(:shelves)
  end
end