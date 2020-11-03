# frozen_string_literal: true

module HomesHelper
  def project_logo(home)
    if home.project_logo.attached?
      logo_url = home.project_logo.service_url
      content_tag :a, href: url_for(root_url) do
        content_tag :img, '', alt: 'project_logo', width: 100, class: 'pull-right', src: logo_url
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
end