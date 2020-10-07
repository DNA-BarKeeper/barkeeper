require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe PrimerRead do
  before(:each) { FactoryBot.create(:project, name: 'All') }

  it_behaves_like "project_record"

  subject { FactoryBot.create(:primer_read) }

  it "is valid with valid attributes" do
    should be_valid
  end

  context "active record attachment" do
    it "validates presence of a chromatogram" do
      is_expected.to validate_attached_of(:chromatogram)
    end

    it "validates content type of chromatogram" do
      is_expected.to validate_content_type_of(:chromatogram)
                         .allowing('application/octet-stream')
    end

    it "is not valid without chromatogram" do
      expect(FactoryBot.build(:primer_read, chromatogram: nil)).to_not be_valid
    end
  end

  it "belongs to a contig" do
    should belong_to(:contig)
  end

  it "belongs to a partial con" do
    should belong_to(:partial_con)
  end

  it "belongs to a primer" do
    should belong_to(:primer)
  end

  it "has many issues" do
    should have_many(:issues).dependent(:destroy)
  end

  it "creates default name before create" do
    should callback(:default_name).before(:create)
  end

  context "class and instance methods" do
    xit "does some stuff" do
    end
  end
end