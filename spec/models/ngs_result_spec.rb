require 'rails_helper'

RSpec.describe NgsResult do
  subject { FactoryBot.create(:ngs_result) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to an NGS run" do
    should belong_to(:ngs_run)
  end

  it "belongs to a marker" do
    should belong_to(:marker)
  end

  it "belongs to an isolate" do
    should belong_to(:isolate)
  end
end