require 'rails_helper'

RSpec.shared_examples "project_record" do
  before(:all) { @general_project = Project.find_or_create_by(name: 'All') }
  before(:all) { @project = FactoryBot.create(:project) }

  let(:record) { FactoryBot.create(described_class.name.underscore.to_sym) }

  it "has and belongs to many projects" do
    should have_and_belong_to_many(:projects)
  end

  it "has one general project added at creation" do
    expect(subject.projects).to include @general_project
  end

  context "and returns" do
    it "all records in given project" do
      subject.projects << @project
      record.projects << @project

      expect(described_class.in_project(@project.id).size).to be == 2
    end

    it "no records for empty project" do
      expect(described_class.in_project(@project.id).size).to be == 0
    end
  end

  context "and adds" do
    it "a list of projects" do
      project_ids = []
      3.times { project_ids << FactoryBot.create(:project).id }

      expect do
        record.add_projects(project_ids)
        record.save
      end.to change { record.projects.count }.by 3
    end

    it "one project" do
      expect do
        record.add_project(@project.id)
        record.save
      end.to change { record.projects.count }.by 1
    end

    it "one project and saves record" do
      expect { record.add_project_and_save(@project.id) }.to change { record.projects.size }.by 1
    end

    it "the same project only once" do
      expect { record.add_project_and_save(@general_project.id) }.not_to change { record.projects.size }
    end
  end
end