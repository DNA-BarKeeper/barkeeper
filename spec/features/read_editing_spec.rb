require "rails_helper"

RSpec.feature "Primer read view and editing", type: :feature, js: true do
  before(:each) { @general_project = Project.find_or_create_by(name: 'All') }

  before :each do
    @primer_read = FactoryBot.create(:primer_read)

    @primer_read.auto_assign
    @primer_read.auto_trim(true)
    @primer_read.update(processed: true, used_for_con: true, assembled: false, comment: 'imported')
  end

  context "view primer read" do
    scenario "Visitor can view primer read" do
      can_view_primer_read
    end

    scenario "Guest can view primer read" do
      user = create(:user, role: 'guest')
      sign_in user

      can_view_primer_read
    end

    scenario "User can view primer read" do
      user = create(:user, role: 'user')
      sign_in user

      can_view_primer_read
    end

    scenario "Supervisor can view primer read" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_view_primer_read
    end

    scenario "Admin can view primer read" do
      user = create(:user, role: 'admin')
      sign_in user

      can_view_primer_read
    end
  end

  context "edit primer read" do
    scenario "Visitor cannot edit primer read" do
      cannot_edit_primer_read
    end

    scenario "Guest cannot edit primer read" do
      user = create(:user, role: 'guest')
      sign_in user

      cannot_edit_primer_read
    end

    scenario "User can edit primer read" do
      user = create(:user, role: 'user')
      sign_in user

      can_edit_primer_read
    end

    scenario "Supervisor can edit primer read" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_edit_primer_read
    end

    scenario "Admin can edit primer read" do
      user = create(:user, role: 'admin')
      sign_in user

      can_edit_primer_read
    end
  end

  context "destroy primer read" do
    scenario "Visitor cannot destroy primer read" do
      cannot_destroy_primer_read
    end

    scenario "Guest cannot destroy primer read" do
      user = create(:user, role: 'guest')
      sign_in user

      cannot_destroy_primer_read
    end

    scenario "User can destroy primer read" do
      user = create(:user, role: 'user')
      sign_in user

      can_destroy_primer_read
    end

    scenario "Supervisor can destroy primer read" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_destroy_primer_read
    end

    scenario "Admin can destroy primer read" do
      user = create(:user, role: 'admin')
      sign_in user

      can_destroy_primer_read
    end
  end

  def can_view_primer_read
    puts "TEST"
    puts @primer_read.sequence

    visit primer_reads_path

    expect(page).to have_link @primer_read.name
    click_on @primer_read.name

    expect(page).to have_content @primer_read.name

    expect(page).to have_content @primer_read.sequence.length.to_s

    expect(page).to have_selector(:id, "chromatogram_container_#{@primer_read.id}", class: 'alignment')
    expect(page).to have_selector(:id, "primer_read_#{@primer_read.id}", class: 'chromatogram')
    expect(page).to have_css('svg')

    expect(page).to have_css('text', id: 'base_60', text: 'A')
    base = find('text', id: 'base_60')

    # Mouseover increases font size of base text, mouseout decreases again
    expect(base['font-size']).to eql '10px'
    base.hover
    expect(base['style']).to eql 'font-size: 14px;'
    find('text', id: 'base_61').hover
    expect(base['style']).to eql 'font-size: 10px;'
  end

  def can_edit_primer_read
    visit primer_reads_path
    click_on @primer_read.name

    # Start automatic trimming
    expect(page).to have_link "Trim sequence based on quality scores"

    click_on "Trim sequence based on quality scores"

    expect(page).to have_content "Sequence trimmed"
    expect(page).to have_css('rect.left_clip_area')
    expect(page).to have_css('rect.right_clip_area')

    # Clicking a base opens a form to change base call
    expect(page).to have_css('text', id: 'base_60', text: 'A')
    base = find('text', id: 'base_60')

    base.click
    within '#base_change' do
      input = find('input')
      input.set 'C'
      input.native.send_keys(:return)
    end
    expect(page).to have_content "Changed base at position 61 to C" # Counting for sequence position starts at 1, not 0
    expect(page).to have_css('text', id: 'base_60', text: 'C')

    # Dragging the clip area changes trimmed read start or end
    left_clip = find('rect.left_clip_area')
    left_drop_base = find('text', id: 'base_119')
    left_clip.drag_to(left_drop_base)
    expect(page).to have_content "Set left clip position to 120"

    right_clip = find('rect.right_clip_area')
    right_drop_base = find('text', id: 'base_239')
    right_clip.drag_to(right_drop_base)
    expect(page).to have_content "Set right clip position to 238"

    expect(find("input#left_clip_#{@primer_read.id}")['value']).to eql '120'
    expect(find("input#right_clip_#{@primer_read.id}")['value']).to eql '238'

    # New trimmed area should be persisted after page refresh
    page.driver.browser.navigate.refresh
    expect(find("input#left_clip_#{@primer_read.id}")['value']).to eql '120'
    expect(find("input#right_clip_#{@primer_read.id}")['value']).to eql '238'
  end

  def cannot_edit_primer_read
    visit primer_reads_path
    click_on @primer_read.name

    expect(page).to have_css('text', id: 'base_60', text: 'A')
    base = find('text', id: 'base_60')

    # Clicking a base opens a form to change base call
    base.click
    within '#base_change' do
      input = find('input')
      input.set 'C'
      input.native.send_keys(:return)
    end

    sleep(0.1) # Otherwise alert is not opened yet
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to eql "Not authorized? Could not change base at position 61 to C"
    alert.accept

    # Dragging the clip area does not change trimmed read start or end
    initial_left_clip = find("input#left_clip_#{@primer_read.id}")['value']
    left_clip = find('rect.left_clip_area')
    left_drop_base = find('text', id: 'base_119')
    left_clip.drag_to(left_drop_base)

    sleep(0.1) # Otherwise alert is not opened yet
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to eql "Not authorized? Could not set left clip at position 120"
    alert.accept

    initial_right_clip = find("input#right_clip_#{@primer_read.id}")['value']
    right_clip = find('rect.right_clip_area')
    right_drop_base = find('text', id: 'base_239')
    right_clip.drag_to(right_drop_base)

    sleep(0.1) # Otherwise alert is not opened yet
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to eql "Not authorized? Could not set right clip at position 238"
    alert.accept

    expect(find("input#left_clip_#{@primer_read.id}")['value']).to eql initial_left_clip
    expect(find("input#right_clip_#{@primer_read.id}")['value']).to eql initial_right_clip
  end

  def cannot_destroy_primer_read
    visit primer_reads_path

    expect {
      find(:xpath, "//a[@href='/primer_reads/#{@primer_read.id}'][@data-method='delete']").click
      alert = page.driver.browser.switch_to.alert
      expect(alert.text).to match "Are you sure?"
      alert.accept
    }.to_not change(PrimerRead,:count)

    expect(page).to have_content "Primer Reads"
    expect(page).to have_content @primer_read.name
  end

  def can_destroy_primer_read
    visit primer_reads_path

    find(:xpath, "//a[@href='/primer_reads/#{@primer_read.id}'][@data-method='delete']").click
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to match "Are you sure?"
    alert.accept

    expect(page).to have_content "Primer Reads"
    expect(page).to_not have_content @primer_read.name
  end
end
