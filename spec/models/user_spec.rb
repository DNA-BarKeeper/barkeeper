require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe User do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:user) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without an email" do
    should validate_presence_of(:email)
  end

  it "is not valid without any projects" do
    should validate_presence_of(:projects)
  end

  it "belongs to one lab" do
    should belong_to(:lab)
  end

  it "has many contig searches" do
    should have_many(:contig_searches)
  end

  it "has many individual searches" do
    should have_many(:individual_searches)
  end

  it "has many marker sequence searches" do
    should have_many(:marker_sequence_searches)
  end

  it "sets a default project before save" do
    should callback(:default_project).before(:save)
  end

  it "assigns a default project" do
    project1 = FactoryBot.create(:project)
    project2 = FactoryBot.create(:project)

    subject.projects << project1
    subject.projects << project2

    expect { subject.save }.to change { subject.reload.default_project_id }.to(project1.id)
  end
end