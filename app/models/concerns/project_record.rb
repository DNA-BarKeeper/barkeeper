# frozen_string_literal: true

# Contains methods used by records with associated projects
module ProjectRecord
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :projects, -> { distinct }

    scope :gbol, -> { in_project(Project.find_by_name('GBOL5')) }

    before_create do
      add_project(0)
    end
  end

  module ClassMethods
    def in_project(project_id)
      joins(:projects).where(projects: { id: project_id }).distinct
    end
  end

  # Adds all of the given projects as well as the general project if not already added
  def add_projects(project_ids)
    project_ids.each { |p| add_single_project(p) }
    add_single_project(Project.where('name like ?', 'All%').first.id)
  end

  # Adds the given project as well as the general project if not already added
  def add_project(project_id)
    add_single_project(project_id)
    add_single_project(Project.where('name like ?', 'All%').first.id)
  end

  def add_project_and_save(project_id)
    add_project(project_id)
    save
  end

  private

  def add_single_project(project_id)
    project = Project.find_by_id(project_id)
    projects << project unless projects.include?(project) || !project
  end
end
