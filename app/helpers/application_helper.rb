module ApplicationHelper
  include AdvancedSearchHelper

  require 'net/http'
  require 'nokogiri'

  def display_base_errors(resource)
    return '' if resource.errors.empty? or resource.errors[:base].empty?
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
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

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = 'GBOL5'

    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
