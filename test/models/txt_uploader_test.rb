# frozen_string_literal: true

require 'test_helper'

class TxtUploaderTest < ActiveSupport::TestCase
  def txt_uploader
    @txt_uploader ||= TxtUploader.new
  end

  def test_valid
    assert txt_uploader.valid?
  end
end
