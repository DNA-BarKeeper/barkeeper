require 'rails_helper'

RSpec.describe PrimerPosOnGenome do
  subject { FactoryBot.create(:primer_pos_on_genome) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "is not valid without a position" do
    should validate_presence_of(:position)
  end

  it "belong to a primer" do
    should belong_to(:primer)
  end

  it "belong to a species" do
    should belong_to(:species)
  end
end