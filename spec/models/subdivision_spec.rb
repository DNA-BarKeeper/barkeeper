require 'rails_helper'

RSpec.describe Subdivision do
  subject { FactoryBot.create(:subdivision) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belong to one division" do
    should belong_to(:division)
  end

  it "has many taxonomic classes" do
    should have_many(:taxonomic_classes)
  end
end