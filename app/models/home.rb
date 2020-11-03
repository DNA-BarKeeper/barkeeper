class Home < ApplicationRecord
  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  has_one_attached :project_logo
  validates :project_logo, content_type: [:jpg, :png, :svg]

  validates_presence_of :title

  attr_accessor :delete_project_logo
  before_validation :remove_project_logo

  attr_accessor :delete_background_image
  before_validation :remove_background_image

  def remove_project_logo
    if delete_project_logo == '1'
      project_logo.purge
    end
  end

  def remove_background_image
    if delete_background_image == '1'
      background_image.purge
    end
  end
end
