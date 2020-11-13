#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
require 'rails_helper'

RSpec.shared_examples "project_record" do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }
  before(:each) { @project = FactoryBot.create(:project) }

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