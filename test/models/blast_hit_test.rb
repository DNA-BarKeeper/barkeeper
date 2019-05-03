require "test_helper"

describe BlastHit do
  let(:blast_hit) { BlastHit.new }

  it "must be valid" do
    value(blast_hit).must_be :valid?
  end
end
