require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe Contig do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:contig) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "belongs to a marker sequence" do
    should belong_to(:marker_sequence)
  end

  it "belongs to a marker" do
    should belong_to(:marker)
  end

  it "belongs to an isolate" do
    should belong_to(:isolate)
  end

  it "has many issues" do
    should have_many(:issues).dependent(:destroy)
  end

  it "has many primer reads" do
    should have_many(:primer_reads).dependent(:destroy)
  end

  it "has many partial cons" do
    should have_many(:partial_cons).dependent(:destroy)
  end

  it "destroys marker sequence if destroyed" do
    ms = FactoryBot.create(:marker_sequence)
    contig = FactoryBot.create(:contig, assembled: true, marker_sequence: ms)

    expect { contig.destroy }.to change { MarkerSequence.all.size }.by -1
  end

  it "destroys marker sequence if unassembled" do
    ms = FactoryBot.create(:marker_sequence)
    contig = FactoryBot.create(:contig, assembled: true, marker_sequence: ms)

    expect { contig.update(assembled: false) }.to change { MarkerSequence.all.size }.by -1
  end

  xit "instance methods"

  xit "class methods"
end