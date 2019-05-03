# frozen_string_literal: true

require 'test_helper'

describe ContigSearch do
  let(:contig_search) { ContigSearch.new }

  it 'must be valid' do
    value(contig_search).must_be :valid?
  end
end
