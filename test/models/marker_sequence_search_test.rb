require "test_helper"

describe MarkerSequenceSearch do
  let(:marker_sequence_search) { MarkerSequenceSearch.new }

  it "must be valid" do
    value(marker_sequence_search).must_be :valid?
  end
end
