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