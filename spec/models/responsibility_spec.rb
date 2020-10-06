require 'rails_helper'

RSpec.describe Responsibility do
  subject { FactoryBot.create(:responsibility) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has and belongs to many users" do
    should have_and_belong_to_many(:users)
  end
end