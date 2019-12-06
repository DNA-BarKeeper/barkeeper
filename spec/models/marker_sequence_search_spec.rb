require 'rails_helper'

RSpec.describe MarkerSequenceSearch do
  subject { FactoryBot.create(:marker_sequence_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one user" do
    should belong_to(:user)
  end

  it "has one project" do
    should belong_to(:project)
  end

  it "belongs to a mislabel analysis" do
    should belong_to(:mislabel_analysis)
  end

  xit "finds records in database"
end