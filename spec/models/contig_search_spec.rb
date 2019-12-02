require 'rails_helper'

RSpec.describe ContigSearch do
  subject { FactoryBot.create(:contig_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one user" do
    assc = described_class.reflect_on_association(:user)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one project" do
    assc = described_class.reflect_on_association(:project)
    expect(assc.macro).to eq :belongs_to
  end
end