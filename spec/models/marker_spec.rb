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

RSpec.describe Marker do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:marker) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has and belongs to many taxa" do
    should have_and_belong_to_many(:taxa)
  end

  it "have many marker sequences" do
    should have_many(:marker_sequences)
  end

  it "have many mislabel_analyses" do
    should have_many(:mislabel_analyses)
  end

  it "have many contigs" do
    should have_many(:contigs)
  end

  it "have many clusters" do
    should have_many(:clusters)
  end

  it "have many ngs results" do
    should have_many(:ngs_results)
  end

  it "have many primers" do
    should have_many(:primers)
  end
end