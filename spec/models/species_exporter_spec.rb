require 'rails_helper'

RSpec.describe SpeciesExporter do
  subject { FactoryBot.create(:species_exporter) }

  it "is valid with valid attributes" do
    should be_valid
  end

  context "active record attachment" do
    it "validates content type of species export" do
      is_expected.to validate_content_type_of(:species_export)
                         .allowing('application/xml')
    end
  end

  xit "creates species export"
end