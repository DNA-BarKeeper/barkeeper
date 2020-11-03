class Home < ApplicationRecord
  has_many :logos

  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title

  attr_accessor :delete_background_image
  before_validation :remove_background_image

  def remove_background_image
    if delete_background_image == '1'
      background_image.purge
    end
  end
end
