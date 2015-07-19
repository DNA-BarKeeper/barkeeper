require 'test_helper'

class IndividualTest < ActiveSupport::TestCase
  test 'should not save project without title' do
    individual = Individual.new
    # assert_not individual.save, 'Saved the Specimen without a specimen_id'
  end
end
