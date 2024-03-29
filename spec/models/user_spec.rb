#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

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
    subject.default_project_id = nil
    subject.projects = []

    project1 = FactoryBot.create(:project)
    project2 = FactoryBot.create(:project)

    subject.add_project(project1.id)
    subject.add_project(project2.id)

    expect { subject.save }.to change { subject.default_project_id }.to(project1.id)
  end
end