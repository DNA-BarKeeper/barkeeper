require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe PlantPlate do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:plant_plate) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "belong to a lab rack" do
    should belong_to(:lab_rack)
  end

  it "has many isolates" do
    should have_many(:isolates)
  end
end