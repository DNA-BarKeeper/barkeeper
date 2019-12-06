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

  context "attached file" do
    it "has attached search result archive" do
      should have_attached_file(:search_result_archive)
    end

    it "validates content type zip" do
      should validate_attachment_content_type(:search_result_archive).allowing('application/zip')
    end

    it "accepts file with correct file name and content type" do
      search_archive = File.new("#{Rails.root}/spec/support/fixtures/search_results.zip")
      expect(FactoryBot.build(:contig_search, search_result_archive: search_archive)).to be_valid
    end

    it "does not accept file with incorrect file name ending" do
      search_archive = File.new("#{Rails.root}/spec/support/fixtures/search_results.txt")
      search = FactoryBot.build(:contig_search, search_result_archive: search_archive)
      expect(search.errors.added?(:search_result_archive_file_name)).to be_truthy
    end

    it "does not accept file with incorrect content type" do
      search_archive = File.new("#{Rails.root}/spec/support/fixtures/text_file.txt")
      search = FactoryBot.build(:contig_search, search_result_archive: search_archive)
      expect(search.errors.added?(:search_result_archive_content_type)).to be_truthy
    end
  end

  context "finds records in database" do

  end

  context "create contig archive" do
    xit "creates a contig archive containing primer reads" do

    end
  end
end