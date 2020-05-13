require 'rails_helper'
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe PrimerRead do
  before(:each) { FactoryBot.create(:project, name: 'All') }

  it_behaves_like "project_record"

  subject { FactoryBot.create(:primer_read) }

  it "is valid with valid attributes" do
    should be_valid
  end

  context "paperclip file attachment" do
    it "has an attached chromatogram file" do
      should have_attached_file(:chromatogram)
    end

    it "validates chromatogram presence" do
      should validate_attachment_presence(:chromatogram)
    end

    it "validates chromatogram content type" do
      should validate_attachment_content_type(:chromatogram)
                 .allowing('application/octet-stream')
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