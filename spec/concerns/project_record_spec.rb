require 'rails_helper'

RSpec.shared_examples "project_record" do
  before(:all) { @project = Project.create(name: 'All') }

  let(:model) { described_class }

  it "has and belongs to many projects" do
    assc = described_class.reflect_on_association(:projects)
    expect(assc.macro).to eq :has_and_belongs_to_many
  end

  context "returns records in project" do
    it "returns all records in given project" do
      FactoryBot.create(:order, projects: [@project]) # TODO: Can this be made generic?
      FactoryBot.create(:order, projects: [@project]) # TODO: Can this be made generic?

      expect(Order.in_project(@project.id).size).to be == 2
    end

    it "returns no records for empty project" do
      expect(Order.in_project(@project.id).size).to be == 0
    end
  end
end