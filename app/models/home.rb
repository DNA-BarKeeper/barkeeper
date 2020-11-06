class Home < ApplicationRecord
  has_one :project_logo, class_name: 'Logo', dependent: :destroy
  has_many :logos, dependent: :destroy

  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title
  validates_length_of :logos, :maximum => 12

  attr_accessor :delete_background_image
  before_validation :remove_background_image

  accepts_nested_attributes_for :project_logo, allow_destroy: true
  accepts_nested_attributes_for :logos, allow_destroy: true

  def remove_background_image
    if delete_background_image == '1'
      background_image.purge
    end
  end
end
