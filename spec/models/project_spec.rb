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

RSpec.describe Project do
  before(:all) { Project.create(name: 'All') }

  subject { FactoryBot.create(:project) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
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

  it "has and belongs to many users" do
    should have_and_belong_to_many(:users)
  end

  it "has and belongs to many primers" do
    should have_and_belong_to_many(:primers)
  end

  it "has and belongs to many markers" do
    should have_and_belong_to_many(:markers)
  end

  it "has and belongs to many issues" do
    should have_and_belong_to_many(:issues)
  end

  context "class and instance methods" do
    xit "does some stuff" do
    end
  end
end