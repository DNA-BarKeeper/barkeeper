#
# Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
# barcode data and metadata.
# Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of Barcode Workflow Manager.
#
# Barcode Workflow Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Barcode Workflow Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Barcode Workflow Manager.  If not, see
# <http://www.gnu.org/licenses/>.
#
# frozen_string_literal: true

# Contains methods used by records with associated projects
module ProjectRecord
  extend ActiveSupport::Concern

  included do
    has_and_belongs_to_many :projects, -> { distinct }
  end

  module ClassMethods
    def in_project(project_id)
      if project_id
        joins(:projects).where(projects: { id: project_id }).distinct
      else
        all
      end
    end
  end

  # Adds all of the given projects if not already added
  def add_projects(project_ids)
    project_ids.each { |p| add_single_project(p) }
  end

  # Adds the given project if not already added
  def add_project(project_id)
    add_single_project(project_id)
  end

  def add_project_and_save(project_id)
    add_project(project_id)
    save
  end

  private

  def add_single_project(project_id)
    if project_id
      project = Project.find_by_id(project_id)
      projects << project unless projects.include?(project) || !project
    end
  end
end
