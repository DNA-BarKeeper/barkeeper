require "test_helper"

class TaxonomicClassTest < ActiveSupport::TestCase

  def taxonomic_class
    @taxonomic_class ||= TaxonomicClass.new
  end

  def test_valid
    assert taxonomic_class.valid?
  end

end
