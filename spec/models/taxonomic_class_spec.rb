require 'rails_helper'

RSpec.describe TaxonomicClass do
  subject { FactoryBot.create(:taxonomic_class) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belong to a subdivision" do
    should belong_to(:subdivision)
  end

  it "has many orders" do
    should have_many(:orders)
  end
end