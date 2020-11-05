# frozen_string_literal: true

module HomesHelper
  def project_logo(home)
    if home.project_logo.attached?
      logo_url = home.project_logo.service_url
      content_tag :a, href: url_for(root_url) do
        content_tag :img, '', alt: 'project_logo', width: 100, class: 'pull-right', src: logo_url.html_safe
      end
    end
  end

  def about_subtitle(home)
    if home.subtitle
      content_tag :small, home.subtitle
    end
  end

  def about_description(home)
    if home.description
      content_tag :small, home.description
    end
  end

  def display_project_logos(home)
    logos_html = +''.html_safe
    if @home.logos.size.positive?
      logos_html << (tag :hr)
      @home.logos.with_attached_image.each do |logo|
        if logo.image.attached? && logo.url
          logos_html << (content_tag :a, href: logo.url, target: '_blank' do
              image_tag logo.image, class: 'partner_logo'
          end)
        end
      end
      logos_html << (tag :hr)
    end

    logos_html
  end
end