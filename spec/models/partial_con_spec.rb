require 'rails_helper'

RSpec.describe PartialCon do
  subject { FactoryBot.create(:partial_con) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a contig" do
    should belong_to(:contig).counter_cache
  end

  it "has many primer reads" do
    should have_many(:primer_reads)
  end

  context "class and instance methods" do
    xit "does some stuff" do
    end
  end
end