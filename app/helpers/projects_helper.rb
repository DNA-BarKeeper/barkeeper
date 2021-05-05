# frozen_string_literal: true

module ProjectsHelper
  def user_projects
    current_user.admin? ? Project.all : current_user.projects
  end
end
