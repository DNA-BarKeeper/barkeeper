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

class OverviewDiagramController < ApplicationController
  include ProjectConcern
  include OverviewDiagramConcern

  def index
    authorize! :index, :overview_diagram
  end

  # returns JSON containing the number of target species for each family
  def all_species
    authorize! :all_species, :overview_diagram
    render json: all_taxa_json(current_project_id)
  end

  # returns JSON with the number of finished species for each family
  def finished_species_marker
    @current_project_id = current_project_id
    authorize! :finished_species_marker, :overview_diagram
    render json: finished_taxa_json(current_project_id, params[:marker_id])
  end
end
