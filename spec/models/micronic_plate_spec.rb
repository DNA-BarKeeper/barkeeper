require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe MicronicPlate do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:micronic_plate) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to one lab rack" do
    should belong_to(:lab_rack)
  end

  it "has many isolates" do
    should have_many(:isolates)
  end

  it "has many aliquots" do
    should have_many(:aliquots)
  end
end