require 'rails_helper'

RSpec.describe HigherOrderTaxon do
  before(:all) { Project.create(name: 'All') }

  subject { FactoryBot.create(:higher_order_taxon) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    subject.name = nil
    should_not be_valid
  end
end