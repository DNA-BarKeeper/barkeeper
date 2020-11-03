# frozen_string_literal: true

module ApplicationHelper
  require 'net/http'
  require 'nokogiri'

  def about_page_style(about_page)
    styles = +''.html_safe

    if about_page
      styles += "class=\"about_page\" "

      home = Home.where(active: true).first
      if home.background_image.attached?
        styles += "style=\"background: url('#{home.background_image.service_url}') no-repeat center fixed;\""
      else
        styles += "style=\"background-color: grey;\""
      end
    else
      styles += "class=\"\""
    end

    styles
  end

  def current_project_name
    if user_signed_in?
      Project.find(current_user.default_project_id).name
    else
      'Project'
    end
  end

  def associated_projects(record)
    projects = if user_signed_in?
                 if record.id?
                   record.projects.where(id: current_user.projects.map(&:id)).select(:id, :name)
                 else
                   current_user.projects.select(:id, :name)
                 end
               else
                 record.projects.select(:id, :name)
               end

    projects
  end

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = 'GBOL5'

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
