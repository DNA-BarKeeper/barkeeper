# frozen_string_literal: true

class Logo < ApplicationRecord
  belongs_to :home

  has_one_attached :image
  validates :image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title

  attr_accessor :delete_image
  before_validation :remove_image

  def remove_image
    if delete_image == '1'
      image.purge
    end
  end
end
