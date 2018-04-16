require "test_helper"

describe Responsibility do
  let(:responsibilities) { Responsibility.new }

  it "must be valid" do
    value(responsibility).must_be :valid?
  end
end
