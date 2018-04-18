module ProjectModule
  def in_project(project_id)
    joins(:projects).where(projects: { id: project_id }).distinct
  end
end