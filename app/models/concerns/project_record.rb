# Contains methods used by records with associated projects
module ProjectRecord
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :projects, -> { distinct }
  end

  def add_project(project_id)
    project = Project.find(project_id)
    projects << project unless projects.include?(project)
  end

  def current_project_id
    # begin
    #   project_id = current_user.default_project_id
    # rescue
    #   project_id = Project.find_by_name('All')
    # end
    user_signed_in? ? current_user.default_project_id : Project.find_by_name('All').id
  end

  module ClassMethods
    def in_project(project_id)
      joins(:projects).where(projects: { id: project_id }).distinct
    end
  end
end