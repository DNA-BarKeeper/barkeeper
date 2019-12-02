require 'rails_helper'

RSpec.describe BlastHit do
  subject { FactoryBot.create(:blast_hit) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one cluster" do
    assc = described_class.reflect_on_association(:cluster)
    expect(assc.macro).to eq :belongs_to
  end
end