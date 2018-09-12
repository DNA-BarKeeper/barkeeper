# frozen_string_literal: true

require 'test_helper'

describe Mislabel do
  let(:mislabel) { Mislabel.new }

  it 'must be valid' do
    value(mislabel).must_be :valid?
  end
end
