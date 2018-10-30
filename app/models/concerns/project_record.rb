# frozen_string_literal: true

# Contains methods used by records with associated projects
module ProjectRecord
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :projects, -> { distinct }

    scope :gbol, -> { in_project(Project.find_by_name('GBOL5')) }
  end

  # Adds the given project as well as the general project if not already added
  def add_project(project_id)
    project = Project.find(project_id)
    project_all = Project.where('name like ?', 'All%').first

    projects << project unless projects.include?(project)
    projects << project_all unless projects.include?(project_all)
  end

  def add_project_and_save(project_id)
    add_project(project_id)
    save
  end

  module ClassMethods
    def in_project(project_id)
      joins(:projects).where(projects: { id: project_id }).distinct
    end
  end
end
