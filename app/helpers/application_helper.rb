# frozen_string_literal: true

module ApplicationHelper
  require 'net/http'
  require 'nokogiri'

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

      html = <<-HTML
      <div class="alert alert-danger">
        <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
        #{compiled_message}
      </div>
      HTML
      html.html_safe
    end
  end

  def display_base_errors(resource)
    return '' if resource.errors.empty? || resource.errors[:base].empty?
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def alert_class(name)
    # name == 'notice' ? 'success' : 'danger'

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
