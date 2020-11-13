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

RSpec.describe Family do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:family) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a name" do
    should validate_presence_of(:name)
  end

  it "has one order" do
    should belong_to(:order)
  end

  it "has many species" do
    should have_many(:species)
  end

  context "returns number of families in higher order taxon" do
    before(:each) { @hot = FactoryBot.create(:higher_order_taxon) }

    it "returns correct number of families in higher order taxon" do
      order = FactoryBot.create(:order, higher_order_taxon: @hot)

      FactoryBot.create(:family, order: order)
      FactoryBot.create(:family, order: order)
      FactoryBot.create(:family, order: order)

      expect(Family.in_higher_order_taxon(@hot.id)).to be == 3
    end

    it "returns correct number for no orders in higher order taxon" do
      expect(Family.in_higher_order_taxon(@hot.id)).to be == 0
    end
  end
end