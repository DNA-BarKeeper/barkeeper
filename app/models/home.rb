class Home < ApplicationRecord
  has_many :logos, dependent: :destroy
  belongs_to :main_logo, class_name: 'Logo', foreign_key: :main_logo_id, dependent: :destroy

  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title
  validates_length_of :logos, :maximum => 12, message: 'You can only add a maximum of 12 logos'

  after_save :process_variant
  after_save :set_main_logo

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

  def set_main_logo
    Logo.update_all(main: false)
    main_logo.update(main: true) if main_logo
  end
end
