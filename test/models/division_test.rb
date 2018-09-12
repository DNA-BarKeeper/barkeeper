# frozen_string_literal: true

require 'test_helper'

class DivisionTest < ActiveSupport::TestCase
  def division
    @division ||= Division.new
  end

  def test_valid
    assert division.valid?
  end
end
