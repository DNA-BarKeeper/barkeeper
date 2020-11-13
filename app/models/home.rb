#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
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
