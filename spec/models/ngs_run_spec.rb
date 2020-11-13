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
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe NgsRun do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:ngs_run) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "ensures name is unique" do
    should validate_uniqueness_of(:name)
  end

  it "belongs to a higher order taxon" do
    should belong_to(:higher_order_taxon)
  end

  it "has many tag primer maps" do
    should have_many(:tag_primer_maps)
  end

  it "has many clusters" do
    should have_many(:clusters).dependent(:destroy)
  end

  it "has many ngs results" do
    should have_many(:ngs_results).dependent(:destroy)
  end

  it "has many isolates" do
    should have_many(:isolates).through(:clusters)
  end

  it "has many markers" do
    should have_many(:markers).through(:ngs_results)
  end

  it "parses package map after save" do
    should callback(:parse_package_map).after(:save)
  end

  context "active record attachment" do
    it "validates content type of set tag map" do
      is_expected.to validate_content_type_of(:set_tag_map)
                         .allowing('text/plain')
    end

    it "validates content type of results" do
      is_expected.to validate_content_type_of(:results)
                         .allowing('application/zip')
    end
  end

  xit "other methods"
end