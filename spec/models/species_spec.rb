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

RSpec.describe Species do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:species) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "assigns display names after save" do
    should callback(:assign_display_names).before(:save)
  end

  it "has many individuals" do
    should have_many(:individuals)
  end

  it "has many primer pos on genome" do
    should have_many(:primer_pos_on_genomes)
  end

  it "belongs to a family" do
    should belong_to(:family)
  end

  context "returns number of species in higher order taxon" do
    before(:each) { @hot = FactoryBot.create(:higher_order_taxon) }

    it "returns correct number of species in higher order taxon" do
      order = FactoryBot.create(:order, higher_order_taxon: @hot)
      family1 = FactoryBot.create(:family, order: order)
      family2 = FactoryBot.create(:family, order: order)

      species1 = FactoryBot.create(:species_with_taxonomy, family: family1, infraspecific: 'sub_a')
      species2 = species1.dup
      species2.update(infraspecific: 'sub_b')

      FactoryBot.create(:species_with_taxonomy, family: family2)

      expect(Species.spp_in_higher_order_taxon(@hot.id)).to be == [2, 3]
    end

    it "returns correct number for no species in higher order taxon" do
      expect(Species.spp_in_higher_order_taxon(@hot.id)).to be == [0, 0]
    end
  end

  context "returns associated family name" do
    it "returns name of associated family if one exists" do
      family = FactoryBot.create(:family)
      species = FactoryBot.create(:species, family: family)

      expect(species.family_name).to be == species.family.name
    end

    it "returns nil if no associated family exists" do
      species = FactoryBot.create(:species, family: nil)
      expect(species.family_name).to be == nil
    end
  end

  context "changes associated family name" do
    it "changes name of associated family if one exists" do
      family1 = FactoryBot.create(:family)
      family2 = FactoryBot.create(:family)
      species = FactoryBot.create(:species, family: family1)

      expect { species.family_name = family2.name }.to change { species.family }.to family2
    end

    it "creates new associated family if none exists" do
      family_name = Faker::Lorem.word

      expect { subject.family_name = family_name }.to change { Family.count }.by 1
    end

    it "does not change associated family if nil is provided" do
      family = FactoryBot.create(:family)
      species = FactoryBot.create(:species, family: family)

      expect { species.family_name = nil }.not_to change { species.family }
    end

    it "removes associated family if an empty string is provided" do
      family = FactoryBot.create(:family)
      species = FactoryBot.create(:species, family: family)

      expect { species.family_name = '' }.to change { species.family }.to nil
    end
  end

  context "returns a species full name" do
    it "returns full name with all parts" do
      species = FactoryBot.create(:species)
      expect(species.full_name).to be == "#{species.genus_name} #{species.species_epithet} #{species.infraspecific}"
    end

    it "returns binomial" do
      species = FactoryBot.create(:species, infraspecific: nil)
      expect(species.full_name).to be == "#{species.genus_name} #{species.species_epithet}"
    end

    it "returns genus" do
      species = FactoryBot.create(:species, species_epithet: nil, infraspecific: nil)
      expect(species.full_name).to be == "#{species.genus_name}"
    end

    it "returns empty string if no name parts are available" do
      species = FactoryBot.create(:species, genus_name: nil, species_epithet: nil, infraspecific: nil)
      expect(species.full_name).to be == ""
    end
  end

  context "returns the species component of a species name" do
    it "returns species component with all parts" do
      species = FactoryBot.create(:species)
      expect(species.get_species_component).to be == "#{species.genus_name} #{species.species_epithet}"
    end

    it "returns genus" do
      species = FactoryBot.create(:species, species_epithet: nil)
      expect(species.get_species_component).to be == "#{species.genus_name}"
    end

    it "returns empty string if no name parts are available" do
      species = FactoryBot.create(:species, genus_name: nil, species_epithet: nil)
      expect(species.get_species_component).to be == ""
    end
  end

  context "returns a species name for display" do
    it "returns binomial if no intraspecific is available" do
      species = FactoryBot.create(:species, infraspecific: nil)
      expect(species.name_for_display).to be == "#{species.genus_name} #{species.species_epithet}"

      species = FactoryBot.create(:species, infraspecific: '')
      expect(species.name_for_display).to be == "#{species.genus_name} #{species.species_epithet}"
    end

    it "returns name with variety info if comment indicates a variety" do
      species = FactoryBot.create(:species, comment: "blablabla\n - is a variety")
      expect(species.name_for_display).to be == "#{species.genus_name} #{species.species_epithet} var. #{species.infraspecific}"
    end

    it "returns name with subspecies indicator otherwise" do
      species = FactoryBot.create(:species)
      expect(species.name_for_display).to be == "#{species.genus_name} #{species.species_epithet} ssp. #{species.infraspecific}"
    end
  end

  xit "imports species data"
end