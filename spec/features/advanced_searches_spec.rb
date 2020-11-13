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
  context "creating searches" do
    scenario "Visitor cannot create search" do
      visit new_marker_sequence_search_path

      expect(page).to have_content "You are not authorized to access this page or perform this action."
      expect(current_path).to eql(root_path)
    end

    scenario "Guest can create search" do
      user = create(:user, role: 'guest')
      sign_in user

      can_create
    end

    scenario "User can create search" do
      user = create(:user, role: 'user')
      sign_in user

      can_create
    end

    scenario "Supervisor can create search" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_create
    end

    scenario "Admin can create search" do
      user = create(:user, role: 'admin')
      sign_in user

      can_create
    end
  end

  context "finding saved searches in profile" do
    scenario "Guest can find saved search" do
      user = create(:user, role: 'guest')
      sign_in user

      can_find_saved_searches(user)
    end

    scenario "User can find saved search" do
      user = create(:user, role: 'user')
      sign_in user

      can_find_saved_searches(user)
    end

    scenario "Supervisor can find saved search" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_find_saved_searches(user)
    end

    scenario "Admin can find saved search" do
      user = create(:user, role: 'admin')
      sign_in user

      can_find_saved_searches(user)
    end
  end


  def can_create
    order = FactoryBot.create(:order)
    family = FactoryBot.create(:family, order: order)
    species1 = FactoryBot.create(:species, family: family, genus_name: "Luzula", species_epithet: "rubella")
    species2 = FactoryBot.create(:species, family: family, genus_name: "Rosa", species_epithet: "arvensis")
    individual1 = FactoryBot.create(:individual, species: species1)
    individual2 = FactoryBot.create(:individual, species: species2)
    isolate1 = FactoryBot.create(:isolate, individual: individual1)
    isolate2 = FactoryBot.create(:isolate, individual: individual2)

    marker_sequence1 = FactoryBot.create(:marker_sequence, isolate: isolate1, name: 'first_test_sequence')
    marker_sequence2 = FactoryBot.create(:marker_sequence, isolate: isolate2, name: 'second_test_sequence')

    visit root_path
    click_on 'All'
    click_on 'Advanced marker sequence search'

    expect(current_path).to eql(new_marker_sequence_search_path)

    fill_in 'Species', :with => species1.composed_name

    expect(page).to have_button "Search"
    click_on 'Search'

    expect(page).to have_content marker_sequence1.name
    expect(page).to_not have_content marker_sequence2.name
  end

  def can_find_saved_searches(user)
    saved_search = FactoryBot.create(:marker_sequence_search)
    second_saved_search = FactoryBot.create(:marker_sequence_search)

    user.marker_sequence_searches << saved_search

    visit root_path

    expect(page).to have_link user.name
    click_on user.name

    expect(page).to have_link "Your past marker sequence searches"
    click_on "Your past marker sequence searches"

    expect(page).to have_content "Advanced Marker Sequence Searches"
    expect(page).to have_content saved_search.title
    expect(page).to_not have_content second_saved_search.title
  end
end