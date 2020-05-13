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

    it "validates search result archive content type" do
      should validate_attachment_content_type(:search_result_archive)
                 .allowing('application/zip')
    end

    # Validate file name
    it { should allow_value("search_results.zip").for(:search_result_archive_file_name) }
    it { should allow_value("search_results.ZIP").for(:search_result_archive_file_name) }
    it { should_not allow_value("search_results.doc").for(:search_result_archive_file_name) }
    it { should_not allow_value("search_results.txt").for(:search_result_archive_file_name) }
  end

  xit "finds records in database" do

  end

  context "create contig archive" do
    xit "creates a contig archive containing primer reads" do

    end
  end
end