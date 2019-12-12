require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Primer do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:primer) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "belongs to a marker" do
    should belong_to(:marker)
  end

  it "has many primer reads" do
    should have_many(:primer_reads)
  end

  it "has many primer pos on genomes" do
    should have_many(:primer_pos_on_genomes)
  end

  context "imports primer data" do
    xit "imports primer data" do
    end
  end
end