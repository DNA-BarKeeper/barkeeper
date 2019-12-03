require 'rails_helper'

RSpec.describe BlastHit do
  subject { FactoryBot.create(:blast_hit) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one cluster" do
    should belong_to(:cluster)
  end
end