require 'rails_helper'

RSpec.describe IndividualSearch do
  subject { FactoryBot.create(:individual_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to one user" do
    should belong_to(:user)
  end

  it "belongs to one project" do
    should belong_to(:project)
  end

  it "is not valid with a duplicate title" do
    should validate_uniqueness_of(:title)
  end

  xit "finds records in database"
end