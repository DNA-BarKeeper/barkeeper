class Issue < ApplicationRecord
  belongs_to :contig
  belongs_to :primer_read
  has_and_belongs_to_many :projects

  def self.in_default_project(project_id)
    joins(:projects).where(projects: { id: project_id }).uniq
  end
end
