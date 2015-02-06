require 'test_helper'

class PrimerReadTest < ActiveSupport::TestCase
  test "must have chromatogram attachment" do
    pr=PrimerRead.new
    assert pr.invalid?
  end
end
