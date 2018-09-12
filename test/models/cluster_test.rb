# frozen_string_literal: true

require 'test_helper'

describe Cluster do
  let(:cluster) { Cluster.new }

  it 'must be valid' do
    value(cluster).must_be :valid?
  end
end
