require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Issue do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:issue) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a contig" do
    should belong_to(:contig)
  end

  it "belongs to a primer read" do
    should belong_to(:primer_read)
  end
end