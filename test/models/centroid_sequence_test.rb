require "test_helper"

describe CentroidSequence do
  let(:centroid_sequence) { CentroidSequence.new }

  it "must be valid" do
    value(centroid_sequence).must_be :valid?
  end
end
