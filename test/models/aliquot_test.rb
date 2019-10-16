require "test_helper"

describe Aliquot do
  let(:aliquot) { Aliquot.new }

  it "must be valid" do
    value(aliquot).must_be :valid?
  end
end
