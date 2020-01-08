require 'rails_helper'

RSpec.describe SpecimenExporter do
  subject { FactoryBot.create(:specimen_exporter) }

  it "is valid with valid attributes" do
    should be_valid
  end

  xit "creates specimen export"
end