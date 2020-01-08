require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe TagPrimerMap do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:tag_primer_map) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to an NGS run" do
    should belong_to(:ngs_run)
  end

  it "sets a name after save" do
    should callback(:set_name).after(:save)
  end

  context "sets a name if a file name is present" do
    it "sets the name to the correct value" do
      subject.tag_primer_map_file_name = "tagPrimerMap_111232B.txt"
      subject.save

      expect(subject.name).to be == "111232B"
    end

    it "chooses correct part of file name if it contains additional info" do
      subject.tag_primer_map_file_name = "tagPrimerMap_111232B_altered.txt"
      subject.save

      expect(subject.name).to be == "111232B"
    end
  end

  xit "does stuff with a tpm file"
end