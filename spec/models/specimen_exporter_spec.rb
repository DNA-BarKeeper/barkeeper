require 'rails_helper'

RSpec.describe SpecimenExporter do
  subject { FactoryBot.create(:specimen_exporter) }

  it "is valid with valid attributes" do
    should be_valid
  end

  context "active record attachment" do
    it "validates content type of specimen export" do
      is_expected.to validate_content_type_of(:specimen_export)
                         .allowing('application/xml')
    end
  end

  xit "creates specimen export"
end