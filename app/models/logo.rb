# frozen_string_literal: true

class Logo < ApplicationRecord
  belongs_to :home
  has_one :home, foreign_key: :main_logo_id

  validates_presence_of :title

  has_one_attached :image
  validates :image, content_type: [:jpg, :png, :svg]

  after_save :process_variant

  def process_variant
    if image.attached?
      image.variant(resize: "100x100").processed
    end
  end
end
