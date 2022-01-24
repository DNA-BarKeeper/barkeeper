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
require Rails.root.join "spec/support/wait_for_ajax.rb"

RSpec.feature "User access to contigs", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }

  context "access contigs index and filter" do
    scenario "Visitor can access contigs index and filter records without login" do
      visit_index_and_filter
    end

    scenario "Guest can access contigs index and filter records" do
      user = create(:user, role: 'guest')
      sign_in user

      visit_index_and_filter
    end

    scenario "User can access contigs index and filter records" do
      user = create(:user, role: 'user')
      sign_in user

      visit_index_and_filter
    end

    scenario "Supervisor can access contigs index and filter records" do
      user = create(:user, role: 'supervisor')
      sign_in user

      visit_index_and_filter
    end

    scenario "Admin can access contigs index and filter records" do
      user = create(:user, role: 'admin')
      sign_in user

      visit_index_and_filter
    end
  end

  scenario "Visitor can access contigs edit page without login" do
    can_edit
  end

  scenario "Visitor cannot update a contig" do
    cannot_update_contig
  end

  scenario "Guest user cannot update a contig" do
    user = create(:user, role: 'guest')
    sign_in user

    cannot_update_contig
  end

  scenario "User can update a contig" do
    user = create(:user, role: 'user')
    sign_in user

    can_update_contig
  end

  scenario "Admin can update a contig" do
    user = create(:user, role: 'admin')
    sign_in user

    can_update_contig
  end

  scenario "Visitor cannot delete a contig without login" do
    cannot_delete_contig
  end

  scenario "Guest user cannot delete a contig" do
    user = create(:user, role: 'guest')
    sign_in user

    cannot_delete_contig
  end

  scenario "User can delete a contig" do
    user = create(:user, role: 'user')
    sign_in user

    can_delete_contig
  end

  scenario "Supervisor can delete a contig" do
    user = create(:user, role: 'supervisor')
    sign_in user

    can_delete_contig
  end

  scenario "Admin can delete a contig" do
    user = create(:user, role: 'admin')
    sign_in user

    can_delete_contig
  end

  def visit_index_and_filter
    first_contig = FactoryBot.create(:contig_with_taxonomy, name: "first_contig")
    second_contig = FactoryBot.create(:contig_with_taxonomy, name: "second_contig")

    species = first_contig.isolate.individual.species
    individual = first_contig.isolate.individual

    visit contigs_path

    within "h3" do
      expect(page).to have_content "Contigs"
    end

    expect(page).to have_content first_contig.name
    expect(page).to have_content second_contig.name

    search_input = find(:xpath, '//input[@type="search"]')

    # Filter by contig name partial
    search_input.set('second')

    expect(page).to_not have_content first_contig.name
    expect(page).to have_content second_contig.name

    # Filter by species name
    search_input.set('')
    search_input.native.send_keys(:return)
    expect(page).to have_content species.name_for_display
    search_input.set(species.name_for_display)

    expect(page).to have_content first_contig.name
    expect(page).to_not have_content second_contig.name

    # Filter by specimen identifier
    search_input.set('')
    search_input.native.send_keys(:return)
    expect(page).to have_content individual.specimen_id
    search_input.set(individual.specimen_id)

    expect(page).to have_content first_contig.name
    expect(page).to_not have_content second_contig.name
  end

  def can_edit
    species = FactoryBot.create(:species_with_individuals)
    FactoryBot.create(:individual_with_isolates, species: species)
    test_contig = FactoryBot.create(:contig, name: "test_contig", isolate: Isolate.first)

    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    within "h3" do
      expect(page).to have_content "Contigs"
    end

    expect(page).to have_content "test_contig"
    expect(page).to have_content "second_test_contig"

    click_link "test_contig"

    expect(current_path).to eq edit_contig_path(test_contig)

    within "h3" do
      expect(page).to have_content "Contig test_contig"
      expect(page).to have_link(species.name_for_display, :href => edit_species_path(species))
    end
  end

  def can_delete_contig
    test_contig = FactoryBot.create(:contig, name: "first_contig")
    FactoryBot.create(:contig, name: "second_contig")

    visit contigs_path

    find(:xpath, "//a[@href='/contigs/#{test_contig.id}'][@data-method='delete']").click
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to match "Are you sure?"
    alert.accept

    expect(page).to have_content "Contigs"
    expect(page).to have_content "second_contig"
    expect(page).to_not have_content "first_contig"

    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  def cannot_delete_contig
    FactoryBot.create(:contig, name: "test_contig")
    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    expect {
      find(:xpath, "//a[@href='/contigs/1']").click
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match "Are you sure?"
      alert.accept
    }.to_not change(Contig,:count)

    expect(page).to have_content "Contigs"
    expect(page).to have_content "test_contig"

    DatabaseCleaner.clean
  end

  def cannot_update_contig
    species = FactoryBot.create(:species_with_individuals)
    FactoryBot.create(:individual_with_isolates, species: species)
    test_contig = FactoryBot.create(:contig, name: "test_contig", isolate: Isolate.first)

    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    click_link 'test_contig'
    click_link 'Description'

    fill_in('Name', :with => 'Changed_Test_Name')

    expect {
      click_button 'Update'
      expect(page).to have_content "You are not authorized to access this page or perform this action."
    }.to_not change(test_contig,:name)

    within "h3" do
      expect(page).to have_content "Contig test_contig"
      expect(page).to have_link(species.name_for_display, :href => edit_species_path(species))
    end

    DatabaseCleaner.clean
  end

  def can_update_contig
    species = FactoryBot.create(:species_with_individuals)
    FactoryBot.create(:individual_with_isolates, species: species)
    test_contig = FactoryBot.create(:contig, name: "test_contig", isolate: Isolate.first)

    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    click_link 'test_contig'
    click_link 'Description'

    fill_in('Name', :with => 'Changed_Test_Name')

    click_button 'Update'
    expect(page).to have_content "Contig was successfully updated."

    within "h3" do
      expect(page).to have_content "Contig Changed_Test_Name"
      expect(page).to have_link(species.name_for_display, :href => edit_species_path(species))
    end

    DatabaseCleaner.clean
  end
end