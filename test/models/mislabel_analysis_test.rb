# frozen_string_literal: true

require 'test_helper'

describe MislabelAnalysis do
  let(:mislabel_analyses) { MislabelAnalysis.new }

  it 'must be valid' do
    value(mislabel_analysis).must_be :valid?
  end
end
