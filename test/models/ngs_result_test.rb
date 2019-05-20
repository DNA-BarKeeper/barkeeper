require "test_helper"

describe NgsResult do
  let(:ngs_result) { NgsResult.new }

  it "must be valid" do
    value(ngs_result).must_be :valid?
  end
end
