require 'rails_helper'

RSpec.describe Mislabel do
  subject { FactoryBot.create(:mislabel) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a mislabel analysis" do
    should belong_to(:mislabel_analysis)
  end

  it "belongs to a marker sequence" do
    should belong_to(:marker_sequence)
  end
end