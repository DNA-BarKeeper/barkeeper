require "rails_helper"

RSpec.feature "User interaction with projects", type: :feature, js: true do
  context "creating projects" do
    scenario "Visitor cannot create project" do
      cannot_create
    end

    scenario "Guest cannot create project" do
      user = create(:user, role: 'guest')
      sign_in user

      cannot_create
    end

    scenario "User cannot create project" do
      user = create(:user, role: 'user')
      sign_in user

      cannot_create
    end

    scenario "Admin can create project" do
      user = create(:user, role: 'admin')
      sign_in user

      can_create
    end

    scenario "Supervisor can create project" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_create
    end
  end

  context "view projects index" do
    scenario "Visitor cannot access projects index" do
      visit projects_path

      expect(page).to have_content "You are not authorized to access this page or perform this action."
      expect(current_path).to eql(root_path)
    end

    scenario "Guest can only see own projects in index" do
      user = create(:user, role: 'guest')
      sign_in user

      can_only_see_own_projects(user)
    end

    scenario "User can only see own projects in index" do
      user = create(:user, role: 'user')
      sign_in user

      can_only_see_own_projects(user)
    end

    scenario "Supervisor can access projects index" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_visit_index
    end

    scenario "Admin can access projects index" do
      user = create(:user, role: 'admin')
      sign_in user

      can_visit_index
    end
  end

  context "show and edit projects" do
    scenario "Visitor cannot show or edit project" do
      project = FactoryBot.create(:project)

      visit project_path(project)

      expect(page).to have_content "You are not authorized to access this page or perform this action."
      expect(current_path).to eql(root_path)

      visit edit_project_path(project)

      expect(page).to have_content "You are not authorized to access this page or perform this action."
      expect(current_path).to eql(root_path)
    end

    scenario "Guest can show own projects only and not edit any" do
      user = create(:user, role: 'guest')
      sign_in user

      can_only_see_own_and_not_edit(user)
    end

    scenario "User can show own projects only and not edit any" do
      user = create(:user, role: 'user')
      sign_in user

      can_only_see_own_and_not_edit(user)
    end

    scenario "Supervisor can show and edit" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_show_and_edit(user)
    end

    scenario "Admin can show and edit" do
      user = create(:user, role: 'admin')
      sign_in user

      can_show_and_edit(user)
    end
  end

  context "updating projects" do
    scenario "Admin can update project" do
      user = create(:user, role: 'admin')
      sign_in user

      can_update
    end

    scenario "Supervisor can update project" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_update
    end
  end

  context "destroying projects" do
    scenario "Guest cannot destroy project" do
      user = create(:user, role: 'guest')
      sign_in user

      cannot_destroy(user)
    end

    scenario "User cannot destroy project" do
      user = create(:user, role: 'user')
      sign_in user

      cannot_destroy(user)
    end

    scenario "Admin can destroy project" do
      user = create(:user, role: 'admin')
      sign_in user

      can_destroy
    end

    scenario "Supervisor can destroy project" do
      user = create(:user, role: 'supervisor')
      sign_in user

      can_destroy
    end
  end


  def can_only_see_own_projects(user)
    project = FactoryBot.create(:project)
    user_project = FactoryBot.create(:project)

    user.projects << user_project

    visit projects_path

    within "h3" do
      expect(page).to have_content "Projects"
    end

    expect(page).to have_content "All"
    expect(page).to have_content user_project.name
    expect(page).to_not have_content project.name

    expect(page).to_not have_link("New Project", :href => new_project_path)

    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  def can_visit_index
    project = FactoryBot.create(:project)
    project2 = FactoryBot.create(:project)

    visit projects_path

    within "h3" do
      expect(page).to have_content "Projects"
    end

    expect(page).to have_content "All"
    expect(page).to have_content project.name
    expect(page).to have_content project2.name

    expect(page).to have_link("New Project", :href => new_project_path)

    Capybara.reset_sessions!
    DatabaseCleaner.clean
  end

  def can_only_see_own_and_not_edit(user)
    user_project = FactoryBot.create(:project)
    project = FactoryBot.create(:project)

    user.projects << user_project

    visit project_path(user_project)

    expect(page).to have_content user_project.name

    visit edit_project_path(user_project)

    expect(page).to have_content "You are not authorized to access this page or perform this action."
    expect(current_path).to eql(root_path)

    visit project_path(project)

    expect(page).to have_content "You are not authorized to access this page or perform this action."
    expect(current_path).to eql(root_path)

    visit edit_project_path(project)

    expect(page).to have_content "You are not authorized to access this page or perform this action."
    expect(current_path).to eql(root_path)
  end

  def can_show_and_edit(user)
    user_project = FactoryBot.create(:project)
    project = FactoryBot.create(:project)

    user.projects << user_project

    visit project_path(user_project)
    expect(page).to have_content user_project.name

    visit edit_project_path(user_project)
    expect(page).to have_content user_project.name
    expect(page).to have_content "submit"

    visit project_path(project)
    expect(page).to have_content project.name

    visit edit_project_path(project)
    expect(page).to have_content project.name
    expect(page).to have_content "submit"
  end

  def cannot_create
    visit new_project_path

    expect(page).to have_content "You are not authorized to access this page or perform this action."
    expect(current_path).to eql(root_path)
  end

  def can_create
    visit projects_path

    expect(page).to have_link("New Project", :href => new_project_path)

    click_on 'New Project'

    expect(current_path).to eql(new_project_path)

    fill_in 'Name', :with => 'Test_Name'
    fill_in 'Description', :with => 'Some text to describe project.'

    expect(page).to have_button "submit"
    click_on 'submit'

    expect(page).to_not have_content "Projects"
    expect(page).to have_content "Test_Name"
  end

  def can_destroy
    test_project = FactoryBot.create(:project, name: "first_project")
    FactoryBot.create(:project, name: "second_project")

    visit projects_path

    find(:xpath, "//a[@href='/projects/#{test_project.id}'][@data-method='delete']").click
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to match "Are you sure?"
    alert.accept

    expect(page).to have_content "Projects"
    expect(page).to have_content "second_project"
    expect(page).to_not have_content "first_project"
  end

  def cannot_destroy(user)
    test_project = FactoryBot.create(:project, name: "first_project")
    second_project = FactoryBot.create(:project, name: "second_project")

    user.projects << test_project
    user.projects << second_project

    visit projects_path

    find(:xpath, "//a[@href='/projects/#{test_project.id}'][@data-method='delete']").click
    alert = page.driver.browser.switch_to.alert
    expect(alert.text).to match "Are you sure?"
    alert.accept

    expect(page).to have_content "You are not authorized to access this page or perform this action."
    expect(current_path).to eql(projects_path)
  end

  def can_update
    project = FactoryBot.create(:project, name: 'initial_name', description: 'old description text')

    visit project_path(project)
    expect(page).to have_content project.name

    visit edit_project_path(project)

    fill_in 'Name', :with => 'new_name'
    fill_in 'Description', :with => 'Some new text to describe project.'

    expect(page).to have_button "submit"
    click_on 'submit'

    expect(current_path).to eql(project_path(project))

    expect(page).to_not have_content "Projects"
    expect(page).to have_content "new_name"
    expect(page).to have_content "Some new text to describe project."

    visit projects_path
    expect(page).to have_content 'new_name'
    expect(page).to have_content "Some new text to describe project."
  end
end
