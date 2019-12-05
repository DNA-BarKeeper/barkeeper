require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe LabRack do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:lab_rack) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belong to a freezer" do
    should belong_to(:freezer)
  end

  it "have many plant plates" do
    should have_many(:plant_plates)
  end

  it "have many micronic plates" do
    should have_many(:micronic_plates)
  end
end