require "test_helper"

class SpeciesXmlUploaderTest < ActiveSupport::TestCase

  def species_xml_uploader
    @species_xml_uploader ||= SpeciesXmlUploader.new
  end

  def test_valid
    assert species_xml_uploader.valid?
  end

end
