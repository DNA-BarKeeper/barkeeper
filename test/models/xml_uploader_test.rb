# frozen_string_literal: true

require 'test_helper'

class XmlUploaderTest < ActiveSupport::TestCase
  def xml_uploader
    @xml_uploader ||= XmlUploader.new
  end

  def test_valid
    assert xml_uploader.valid?
  end
end
