require "test_helper"

describe TagPrimerMap do
  let(:tag_primer_map) { TagPrimerMap.new }

  it "must be valid" do
    value(tag_primer_map).must_be :valid?
  end
end
