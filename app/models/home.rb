class Home < ApplicationRecord
  has_many :logos, dependent: :destroy

  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title
  validates_length_of :logos, :maximum => 13

  after_save :process_variant

  attr_accessor :delete_background_image
  before_validation :remove_background_image

  accepts_nested_attributes_for :logos, allow_destroy: true

  def remove_background_image
    if delete_background_image == '1'
      background_image.purge
    end
  end

  def process_variant
    if background_image.attached?
      background_image.variant(resize: "100x100").processed
    end
  end

  def has_project_logo
    logos.where(partner: false).size.positive?
  end

  def project_logo
    logos.where(partner: false).first
  end
end
