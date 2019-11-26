# frozen_string_literal: true

require 'test_helper'

describe NgsRun do
  let(:ngs_run) { NgsRun.new }

  it 'must be valid' do
    value(ngs_run).must_be :valid?
  end
end
