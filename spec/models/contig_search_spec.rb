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

  context "active record attachment" do
    it "validates content type of search result archive" do
      is_expected.to validate_content_type_of(:search_result_archive)
                         .allowing('application/zip')
    end

    it "is valid with valid search result archive" do
      with_attachment = FactoryBot.create(:contig_search_valid_attachment)
      expect(with_attachment).to be_valid
    end

    it "is not valid with a duplicate title" do
      should validate_uniqueness_of(:title).scoped_to(:user_id)
    end
  end

  xit "finds records in database" do

  end

  context "create contig archive" do
    xit "creates a contig archive containing primer reads" do

    end
  end
end