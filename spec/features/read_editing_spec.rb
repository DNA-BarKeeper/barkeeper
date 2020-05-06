require "rails_helper"

RSpec.feature "Primer read view and editing", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }

  before :each do
    marker = FactoryBot.create(:marker)

    primer1 = FactoryBot.create(:primer, name: 'cp148', marker: marker)
    chromatogram1 = fixture_file_upload('files/GBoL1000_cp148.scf')

    primer2 = FactoryBot.create(:primer, name: 'cp149', marker: marker)
    chromatogram2 = fixture_file_upload('files/GBoL1000_cp149.scf')

    @contig = FactoryBot.create(:contig_with_taxonomy, name: "GBoL1000_#{marker.name}", marker: marker)

    @primer_read1 = FactoryBot.create(:primer_read, name: 'GBoL1000_cp148', chromatogram: chromatogram1)
    @primer_read1.auto_assign
    @primer_read1.auto_trim(true)

    p @primer_read1.primer

    @primer_read2 = FactoryBot.create(:primer_read, name: 'GBoL1000_cp149', chromatogram: chromatogram2)
    @primer_read2.auto_assign
    @primer_read2.auto_trim(true)

    @contig.primer_reads << @primer_read1
    @contig.primer_reads << @primer_read2

    @species = @contig.isolate.individual.species
  end

  context "view primer read" do
    scenario "Visitor can view primer read" do
      can_view_primer_read
    end

    # scenario "Guest can view primer read" do
    #   user = create(:user, role: 'guest')
    #   sign_in user
    #
    #   can_view_primer_read
    # end
    #
    # scenario "User can view primer read" do
    #   user = create(:user, role: 'user')
    #   sign_in user
    #
    #   can_view_primer_read
    # end
    #
    # scenario "Supervisor can view primer read" do
    #   user = create(:user, role: 'supervisor')
    #   sign_in user
    #
    #   can_view_primer_read
    # end
    #
    # scenario "Admin can view primer read" do
    #   user = create(:user, role: 'admin')
    #   sign_in user
    #
    #   can_view_primer_read
    # end
  end

  def can_view_primer_read
    visit primer_reads_path

    expect(page).to have_link @primer_read1.name
    click_on @primer_read1.name

    expect(page).to have_content @primer_read1.name
    expect(page).to have_link @species.name_for_display

    expect(page).to have_link "Go to contig #{@contig.name}"

    # expect(page).to have_content @primer_read1.sequence.length.to_s
  end
end
