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
    taxon1 = FactoryBot.create(:taxon, scientific_name: "Luzula rubella")
    taxon2 = FactoryBot.create(:taxon, scientific_name: "Rosa arvensis")
    individual1 = FactoryBot.create(:individual, taxon: taxon1)
    individual2 = FactoryBot.create(:individual, taxon: taxon2)
    isolate1 = FactoryBot.create(:isolate, individual: individual1)
    isolate2 = FactoryBot.create(:isolate, individual: individual2)

    marker_sequence1 = FactoryBot.create(:marker_sequence, isolate: isolate1, name: 'first_test_sequence')
    marker_sequence2 = FactoryBot.create(:marker_sequence, isolate: isolate2, name: 'second_test_sequence')

    visit root_path
    click_on 'All'
    click_on 'Advanced marker sequence search'

    expect(current_path).to eql(new_marker_sequence_search_path)

    fill_in 'Taxon', :with => taxon1.scientific_name

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