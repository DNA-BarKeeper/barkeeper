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

RSpec.describe Individual do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:individual) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a taxon" do
    should belong_to(:taxon)
  end

  it "belongs to a collection" do
    should belong_to(:collection)
  end

  it "belongs to a tissue" do
    should belong_to(:tissue)
  end

  it "has many isolates" do
    should have_many(:isolates)
  end

  it "assigns DNA bank info after save" do
    should callback(:assign_dna_bank_info).after(:save).if :identifier_has_changed?
  end

  it "updates tissue after save" do
    should callback(:update_isolate_tissue).after(:save).if :saved_change_to_tissue_id?
  end

  xit "returns csv" do; end

  xit "assigns DNA bank info" do; end

  context "returns associated taxon name" do
    it "returns name of associated taxon if one exists" do
      taxon = FactoryBot.create(:taxon)
      individual = FactoryBot.create(:individual, taxon: taxon)

      expect(individual.taxon_name).to be == taxon.scientific_name
    end

    it "returns nil if no associated taxon exists" do
      individual = FactoryBot.create(:individual, taxon: nil)
      expect(individual.taxon_name).to be == nil
    end
  end

  context "changes associated taxon name" do
    it "changes name of associated taxon if one exists" do
      taxon1 = FactoryBot.create(:taxon)
      taxon2 = FactoryBot.create(:taxon)

      individual = FactoryBot.create(:individual, taxon: taxon1)

      expect { individual.taxon_name = taxon2.scientific_name }.to change { individual.taxon }.to taxon2
    end

    it "creates new associated taxon if none exists" do
      taxon_name = Faker::Lorem.word

      expect { subject.taxon_name = taxon_name }.to change { Taxon.count }.by 1
    end

    it "does not change associated taxon if nil is provided" do
      taxon = FactoryBot.create(:taxon)
      individual = FactoryBot.create(:individual, taxon: taxon)

      expect { individual.taxon_name = nil }.not_to change { individual.taxon }
    end

    it "removes associated taxon if an empty string is provided" do
      taxon = FactoryBot.create(:taxon)
      individual = FactoryBot.create(:individual, taxon: taxon)

      expect { individual.taxon_name = '' }.to change { individual.taxon }.to nil
    end
  end

  context "updates isolates tissue" do
    it "updates tissue of all associated isolates" do
      individual = FactoryBot.create(:individual)
      isolate = FactoryBot.create(:isolate, individual: individual)
      tissue = FactoryBot.create(:tissue)

      expect { individual.update(tissue: tissue) }.to change { isolate.reload.tissue }.to(tissue)
    end
  end
end