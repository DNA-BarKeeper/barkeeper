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
require "rails_helper"

RSpec.feature "Advanced marker sequence searches", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }
  #
  # context "view diagrams" do
  #   scenario "Visitor can view overview diagrams" do
  #     can_view_diagrams
  #   end
  #
  #   scenario "Guest can view overview diagrams" do
  #     user = create(:user, role: 'guest', default_project_id: @general_project.id)
  #     sign_in user
  #
  #     can_view_diagrams
  #   end
  #
  #   scenario "User can view overview diagrams" do
  #     user = create(:user, role: 'user', default_project_id: @general_project.id)
  #     sign_in user
  #
  #     can_view_diagrams
  #   end
  #
  #   scenario "Supervisor can view overview diagrams" do
  #     user = create(:user, role: 'supervisor', default_project_id: @general_project.id)
  #     sign_in user
  #
  #     can_view_diagrams
  #   end
  #
  #   scenario "Admin can view overview diagrams" do
  #     user = create(:user, role: 'admin', default_project_id: @general_project.id)
  #     sign_in user
  #
  #     can_view_diagrams
  #   end
  # end
  #
  # def can_view_diagrams
  #   10.times { FactoryBot.create(:marker_sequence_with_taxonomy) }
  #
  #   visit overview_diagram_index_path
  #   expect(current_path).to eql(overview_diagram_index_path)
  #
  #   expect(page).to have_link "View overview tables"
  #
  #   # All species
  #   expect(page).to have_content "Number of species per taxon"
  #   expect(page).to have_selector(:id, 'all_species', class: 'overview_diagram')
  #   expect(page).to have_selector(:id, 'sequence1', class: 'sequence')
  #   expect(page).to have_selector(:id, 'chart1', class: 'chart')
  #
  #   chart1 = page.find(:id, 'chart1', class: 'chart')
  #   within chart1 do
  #     expect(page).to have_css('svg')
  #     expect(page).to have_css('path')
  #     expect(page).to have_selector('#explanation1', class: 'explanation', visible: false)
  #     find('path', match: :first).hover
  #     expect(page).to have_selector('#explanation1', class: 'explanation', visible: true)
  #   end
  #
  #   # Marker specific
  #   expect(page).to have_content "Number of barcode sequences"
  #   expect(page).to have_selector(:id, 'sequence2', class: 'sequence')
  #   expect(page).to have_selector(:id, 'chart2', class: 'chart')
  #
  #   chart2 = page.find(:id, 'chart2', class: 'chart')
  #   within chart2 do
  #     expect(page).to have_css('svg')
  #     expect(page).to have_css('path')
  #     expect(page).to have_selector('#explanation2', class: 'explanation', visible: false)
  #   end
  #
  #   Capybara.reset_sessions!
  #   DatabaseCleaner.clean
  # end
end
