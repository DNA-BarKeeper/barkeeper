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

require "rails_helper"

RSpec.feature "Public access to static pages", type: :feature do
  scenario "visitor sees about page at root" do
    visit root_path

    within "h1" do
      expect(page).to have_content "BarKeeper"
    end

    have_link("Legal disclosure", :href => legal_disclosure_url)
    have_link("Privacy policy", :href => privacy_policy_url)
  end

  scenario "visitor sees legal disclosure" do
    visit legal_disclosure_path

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
    expect(page).to have_content "9 Right of appeal at the regulating authority"
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