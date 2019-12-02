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
    assc = described_class.reflect_on_association(:isolate)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one ngs_run" do
    assc = described_class.reflect_on_association(:ngs_run)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one marker" do
    assc = described_class.reflect_on_association(:marker)
    expect(assc.macro).to eq :belongs_to
  end

  it "has one blast hit" do
    assc = described_class.reflect_on_association(:blast_hit)
    expect(assc.macro).to eq :has_one
  end

  it "destroys dependent blast hits" do
    blast_hit = FactoryBot.create(:blast_hit)
    cluster = FactoryBot.create(:cluster, blast_hit: blast_hit)

    expect { cluster.destroy }.to change { BlastHit.count }.by(-1)
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