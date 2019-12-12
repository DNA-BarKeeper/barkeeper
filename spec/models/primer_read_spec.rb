require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe PrimerRead do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:primer_read) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a contig" do
    should belong_to(:contig)
  end

  it "belongs to a partial con" do
    should belong_to(:partial_con)
  end

  it "belongs to a primer" do
    should belong_to(:primer)
  end

  it "has many issues" do
    should have_many(:issues).dependent(:destroy)
  end

  it "creates default name before create" do
    should callback(:default_name).before(:create)
  end

  context "class and instance methods" do
    xit "does some stuff" do
    end
  end
end