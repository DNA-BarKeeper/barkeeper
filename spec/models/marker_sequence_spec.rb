require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe MarkerSequence do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:marker_sequence) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a marker" do
    should belong_to(:marker)
  end

  it "belong to an isolate" do
    should belong_to(:isolate)
  end

  it "has many contigs" do
    should have_many(:contigs)
  end

  it "has many mislabels" do
    should have_many(:mislabels).dependent(:destroy)
  end

  it "has and belongs to many mislabel analyses" do
    should have_and_belong_to_many(:mislabel_analyses)
  end

  context "returns associated isolate's display name" do
    it "returns display name of associated isolate if one exists" do
      isolate = FactoryBot.create(:isolate)
      ms = FactoryBot.create(:marker_sequence, isolate: isolate)

      expect(ms.isolate_display_name).to be == isolate.display_name
    end

    it "returns nil if no associated isolate exists" do
      ms = FactoryBot.create(:marker_sequence, isolate: nil)
      expect(ms.isolate_display_name).to be == nil
    end
  end

  context "changes associated isolate's display name" do
    it "changes display name of associated isolate if one exists" do
      isolate1 = FactoryBot.create(:isolate)
      isolate2 = FactoryBot.create(:isolate)
      ms = FactoryBot.create(:marker_sequence, isolate: isolate1)

      expect { ms.isolate_display_name = isolate2.display_name }.to change { ms.isolate }.to isolate2
    end

    it "does not change associated isolate if no isolate with the provided display name is found" do
      isolate_id = Faker::Lorem.word
      isolate = FactoryBot.create(:isolate)
      ms = FactoryBot.create(:marker_sequence, isolate: isolate)

      expect { ms.isolate_display_name = isolate_id }.not_to change { ms.isolate }
    end

    it "does not change associated isolate if nil is provided" do
      isolate = FactoryBot.create(:isolate)
      ms = FactoryBot.create(:marker_sequence, isolate: isolate)

      expect { ms.isolate_display_name = nil }.not_to change { ms.isolate }
    end

    it "removes associated isolate if an empty string is provided" do
      isolate = FactoryBot.create(:isolate)
      ms = FactoryBot.create(:marker_sequence, isolate: isolate)

      expect { ms.isolate_display_name = '' }.to change { ms.isolate }.to nil
    end
  end

  xit "other methods"
end