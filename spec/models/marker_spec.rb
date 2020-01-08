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

  it "has and belongs to many higher order taxa" do
    should have_and_belong_to_many(:higher_order_taxa)
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

  context "returns number of marker sequences in higher order taxon" do
    before(:all) { @marker = FactoryBot.create(:marker) }
    before(:each) { @hot = FactoryBot.create(:higher_order_taxon) }

    it "returns correct number of species in higher order taxon" do
      order = FactoryBot.create(:order, higher_order_taxon: @hot)
      family1 = FactoryBot.create(:family, order: order)
      family2 = FactoryBot.create(:family, order: order)
      species1 = FactoryBot.create(:species, family: family1)
      species2 = FactoryBot.create(:species, family: family1)
      species3 = FactoryBot.create(:species, family: family2)
      individual1 = FactoryBot.create(:individual, species: species1)
      individual2 = FactoryBot.create(:individual, species: species2)
      individual3 = FactoryBot.create(:individual, species: species3)
      isolate1 = FactoryBot.create(:isolate, individual: individual1)
      isolate2 = FactoryBot.create(:isolate, individual: individual2)
      isolate3 = FactoryBot.create(:isolate, individual: individual3)
      FactoryBot.create(:marker_sequence, isolate: isolate1, marker: @marker)
      FactoryBot.create(:marker_sequence, isolate: isolate2, marker: @marker)
      FactoryBot.create(:marker_sequence, isolate: isolate3, marker: @marker)

      expect(@marker.spp_in_higher_order_taxon(@hot.id)).to be == [3, 3, 3]
    end

    it "returns zero if no species belong to higher order taxon" do
      expect(@marker.spp_in_higher_order_taxon(@hot.id)).to be == [0, 0, 0]
    end
  end
end