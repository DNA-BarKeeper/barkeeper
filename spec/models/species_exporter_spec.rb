require 'rails_helper'

RSpec.describe SpeciesExporter do
  subject { FactoryBot.create(:species_exporter) }

  it "is valid with valid attributes" do
    should be_valid
  end

  xit "creates species export"
end