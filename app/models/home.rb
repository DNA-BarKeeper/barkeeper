#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#

class Home < ApplicationRecord
  has_many :logos, dependent: :destroy
  belongs_to :main_logo, class_name: 'Logo', foreign_key: :main_logo_id, dependent: :destroy

  has_one_attached :background_image
  validates :background_image, content_type: [:jpg, :png, :svg]

  validates_presence_of :title
  validates_length_of :logos, :maximum => 12, message: 'You can only add a maximum of 12 logos'

  after_save :set_main_logo

  accepts_nested_attributes_for :logos, allow_destroy: true

  def set_main_logo
    Logo.update_all(main: false)
    main_logo.update(main: true) if main_logo
  end

  def remove_background_image_attachment
    self.background_image.purge
  end
end
