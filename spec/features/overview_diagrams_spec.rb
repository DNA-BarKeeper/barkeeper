require "rails_helper"

RSpec.feature "Advanced marker sequence searches", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }

  context "view diagrams" do
    scenario "Visitor can view overview diagrams" do
      can_view_diagrams
    end

    scenario "Guest can view overview diagrams" do
      user = create(:user, role: 'guest', default_project_id: @general_project.id)
      sign_in user

      can_view_diagrams
    end

    scenario "User can view overview diagrams" do
      user = create(:user, role: 'user', default_project_id: @general_project.id)
      sign_in user

      can_view_diagrams
    end

    scenario "Supervisor can view overview diagrams" do
      user = create(:user, role: 'supervisor', default_project_id: @general_project.id)
      sign_in user

      can_view_diagrams
    end

    scenario "Admin can view overview diagrams" do
      user = create(:user, role: 'admin', default_project_id: @general_project.id)
      sign_in user

      can_view_diagrams
    end
  end

  def can_view_diagrams
    10.times { FactoryBot.create(:marker_sequence_with_taxonomy) }

    visit overview_diagram_index_path
    expect(current_path).to eql(overview_diagram_index_path)

    expect(page).to have_link "View overview tables"

    # All species
    expect(page).to have_content "Number of species per taxon"
    expect(page).to have_selector(:id, 'all_species', class: 'overview_diagram')
    expect(page).to have_selector(:id, 'sequence1', class: 'sequence')
    expect(page).to have_selector(:id, 'chart1', class: 'chart')

    chart1 = page.find(:id, 'chart1', class: 'chart')
    within chart1 do
      expect(page).to have_css('svg')
      expect(page).to have_css('path')
      expect(page).to have_selector('#explanation1', class: 'explanation', visible: false)
      find('path', match: :first).hover
      expect(page).to have_selector('#explanation1', class: 'explanation', visible: true)
    end

    # Marker specific
    expect(page).to have_content "Number of barcode sequences"
    expect(page).to have_selector(:id, 'sequence2', class: 'sequence')
    expect(page).to have_selector(:id, 'chart2', class: 'chart')

    chart2 = page.find(:id, 'chart2', class: 'chart')
    within chart2 do
      expect(page).to have_css('svg')
      expect(page).to have_css('path')
      expect(page).to have_selector('#explanation2', class: 'explanation', visible: false)
    end

    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end
end
