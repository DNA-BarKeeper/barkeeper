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

RSpec.describe Cluster do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:cluster) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one isolate" do
    should belong_to(:isolate)
  end

  it "has one ngs_run" do
    should belong_to(:ngs_run)
  end

  it "has one marker" do
    should belong_to(:marker)
  end

  it "has one blast hit and destroys it on deletion" do
    should have_one(:blast_hit).dependent(:destroy)
  end

  context "returns associated isolate name" do
    it "returns name of associated isolate if one exists" do
      isolate = FactoryBot.create(:isolate)
      cluster = FactoryBot.create(:cluster, isolate: isolate)

      expect(cluster.isolate_name).to be == isolate.display_name
    end

    it "returns nil if no associated isolate exists" do
      cluster = FactoryBot.create(:cluster, isolate: nil)
      expect(cluster.isolate_name).to be == nil
    end
  end
end