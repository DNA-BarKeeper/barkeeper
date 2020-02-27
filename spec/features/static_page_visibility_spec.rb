require "rails_helper"

RSpec.feature "Public access to static pages", type: :feature do
  scenario "visitor sees about page at root" do
    visit root_path

    within "h1" do
      expect(page).to have_content "GBOL5"
    end

    have_link("Legal disclosure", :href => impressum_url)
    have_link("Privacy policy", :href => privacy_policy_url)
  end

  scenario "visitor sees legal disclosure" do
    visit impressum_path

    within "h3" do
      expect(page).to have_content "Legal disclosure"
    end

    expect(page).to have_content "Organisation"
    expect(page).to have_content "Inspecting authority"
  end

  scenario "visitor sees privacy policy" do
    visit privacy_policy_path

    within "h3" do
      expect(page).to have_content "Privacy Policy"
    end

    expect(page).to have_content "1 Collection and processing of personal data"
    expect(page).to have_content "5 Sharing and disclosure of personal data to third parties"
    expect(page).to have_content "10 Right of appeal at the regulating authority"
  end

  scenario "visitor sees overview page" do
    visit overview_path

    time = Time.now.in_time_zone("CET").strftime("%Y-%m-%d %H:%M:") # Skipped seconds because tests will fail if not (time changes)

    within "h3" do
      expect(page).to have_content "Overview"
    end

    expect(page).to have_content "Taxa"
    expect(page).to have_content "GBOL5 Markers"
    expect(page).to have_content "bp sequenced as of #{time}"
    expect(page).to have_content "Total"

    have_link("Back to overview diagrams", :href => overview_diagram_index_url)
  end
end