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
# frozen_string_literal: true

module ApplicationHelper
  require 'net/http'
  require 'nokogiri'

  def about_page_style(about_page)
    styles = +''

    if about_page
      styles += "class=\"about_page\" "

      home = Home.where(active: true).first
      if home.background_image.attached?
        styles += "style=\"background: url(#{url_for(home.background_image)}) no-repeat center fixed;\""
      else
        styles += "style=\"background-color: grey;\""
      end
    else
      styles += "class=\"\""
    end

    styles.html_safe
  end

  def current_project_name
    if user_signed_in? && current_user.default_project_id.present?
      Project.find(current_user.default_project_id).name
    else
      'Project'
    end
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = ENV.fetch('MAIN_PROJECT_NAME', 'New initiative')

    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def show_val_errors(resource)
    if resource.errors.any?
      compiled_message = pluralize(resource.errors.count, 'error') + ': '

      resource.errors.full_messages.each do |msg|
        compiled_message += (msg + '. ')
      end

      message_div = content_tag :div, class: ['alert', 'alert-danger'] do
        content_tag(:button, "×", type: 'button', class: 'close', data: { dismiss: 'alert' }, 'aria-hidden' => true) +
        compiled_message
      end

      message_div
    end
  end

  def display_base_errors(resource)
    return '' if resource.errors.empty? || resource.errors[:base].empty?

    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join

    content_tag :div, class: %w(alert alert-error alert-block) do
      content_tag(:button, "×", type: 'button', class: 'close',
                  data: { dismiss: 'alert' }) +
      messages
    end
  end

  def alert_class(name)
    case name
    when 'notice'
      'success'
    when 'warning'
      'warning'
    else
      'danger'
    end
  end
end
