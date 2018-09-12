# frozen_string_literal: true

require 'test_helper'

class SubdivisionTest < ActiveSupport::TestCase
  def subdivision
    @subdivision ||= Subdivision.new
  end

  def test_valid
    assert subdivision.valid?
  end
end
