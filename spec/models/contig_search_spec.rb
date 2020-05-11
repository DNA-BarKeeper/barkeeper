require 'rails_helper'

RSpec.describe ContigSearch do
  subject { FactoryBot.create(:contig_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one user" do
    should belong_to(:user)
  end

  it "has one project" do
    should belong_to(:project)
  end

  context "has paperclip file attachment" do
    it "has attached search result archive" do
      should have_attached_file(:search_result_archive)
    end

    it "validates content type zip" do
      should validate_attachment_content_type(:search_result_archive)
                 .allowing('application/zip')
                 .rejecting('text/plain', 'text/xml')
    end

    it "does not accept file with incorrect file name ending" do
      search = FactoryBot.build(:contig_search_incorrect_file_ending)
      expect(search.errors.added?(:search_result_archive_file_name)).to be_truthy
    end

    it "does not accept file with incorrect content type" do
      search = FactoryBot.build(:contig_search_text_file)
      expect(search.errors.added?(:search_result_archive_content_type)).to be_truthy
    end
  end

  xit "finds records in database" do

  end

  context "create contig archive" do
    xit "creates a contig archive containing primer reads" do

    end
  end
end