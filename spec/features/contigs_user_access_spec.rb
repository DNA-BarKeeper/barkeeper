require "rails_helper"

RSpec.feature "User access to contigs", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }

  scenario "Visitor can access contigs index and edit pages without login" do
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

  scenario "visitor cannot delete a contig" do
    FactoryBot.create(:contig, name: "test_contig")
    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    expect {
      find(:xpath, "//a[@href='/contigs/1']").click
      alert = page.driver.browser.switch_to.alert
      alert.accept
    }.to_not change(Contig,:count)

    expect(page).to have_content "Contigs"
    expect(page).to have_content "test_contig"

    DatabaseCleaner.clean
  end

  scenario "visitor cannot edit a contig" do
    species = FactoryBot.create(:species_with_individuals)
    FactoryBot.create(:individual_with_isolates, species: species)
    test_contig = FactoryBot.create(:contig, name: "test_contig", isolate: Isolate.first)

    FactoryBot.create(:contig, name: "second_test_contig")

    visit contigs_path

    click_link 'test_contig'
    click_link 'Description'

    fill_in('Name', :with => 'Changed_Test_Name')

    click_button 'Update'

    alert = page.driver.browser.switch_to.alert
    expect { alert.text }.to be "You are not authorized to access this page or perform this action."

    within "h3" do
      expect(page).to have_content "Contig test_contig"
      expect(page).to have_link(species.name_for_display, :href => edit_species_path(species))
    end
  end
end