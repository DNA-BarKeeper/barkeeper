# Contains methods used by records with associated projects
module ProjectModule
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def in_project(project_id)
      joins(:projects).where(projects: { id: project_id }).distinct
    end
  end

  def add_project(project_id)
    project = Project.find(project_id)
    projects << project unless projects.include?(project)
  end
end