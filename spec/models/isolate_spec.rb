require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Isolate do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:isolate) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a display name" do
    subject.dna_bank_id = nil
    subject.lab_isolation_nr = nil
    should validate_presence_of(:display_name).
                with_message('Either a DNA Bank Number or a lab isolation number must be provided!')
  end

  it "belongs to a micronic plate" do
    should belong_to(:micronic_plate)
  end

  it "belongs to a plant plate" do
    should belong_to(:plant_plate)
  end

  it "belongs to a tissue" do
    should belong_to(:tissue)
  end

  it "belongs to an individual" do
    should belong_to(:individual)
  end

  it "has many marker sequences" do
    should have_many(:marker_sequences)
  end

  it "has many contigs" do
    should have_many(:contigs)
  end

  it "has many clusters" do
    should have_many(:clusters)
  end

  it "has many ngs_results" do
    should have_many(:ngs_results)
  end

  it "has many ngs_runs" do
    should have_many(:ngs_runs).through(:clusters)
  end

  it "has many aliquots" do
    should have_many(:aliquots)
  end

  it "assigns a display name before validation" do
    should callback(:assign_display_name).before(:validation)
  end

  it "assigns a specimen after save" do
    should callback(:assign_specimen).after(:save)
  end

  xit "other methods"
end