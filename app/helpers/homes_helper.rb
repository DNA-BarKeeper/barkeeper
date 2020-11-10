# frozen_string_literal: true

module HomesHelper
  def main_project_logo
    if @home.has_project_logo && @home.project_logo.image&.attached?
      logo_url = @home.project_logo.image.service_url
      content_tag :a, href: @home.project_logo.url do
        content_tag :img, '', alt: 'project_logo', width: 100, class: 'pull-right', src: logo_url.html_safe
      end
    end
  end

  def about_subtitle
    if @home.subtitle
      content_tag :small, @home.subtitle
    end
  end

  def about_description
    if @home.description
      content_tag :small, @home.description
    end
  end

  def display_project_logos
    logos_html = +''.html_safe

    if @home.logos.size.positive?
      @home.logos.with_attached_image.each do |logo|
        if logo.image.attached? && logo.url
          logos_html << (content_tag :div, style: 'height: 70px;', class: "col-sm-#{@home.logos.size}" do
            content_tag :a, href: logo.url, target: '_blank' do
              image_tag logo.image, class: 'partner_logo'
            end
          end)
        end
      end
    end

    logos_html
  end
end