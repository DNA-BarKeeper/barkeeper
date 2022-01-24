#
# BarKeeper - A versatile web framework to assemble, analyze and manage DNA
# barcoding data and metadata.
# Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
# <sarah.wiechers@uni-muenster.de>
#
# This file is part of BarKeeper.
#
# BarKeeper is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# BarKeeper is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
#
# frozen_string_literal: true

class ProgressOverviewController < ApplicationController
  include ProjectConcern
  include ProgressOverviewConcern

  def index
    authorize! :index, :progress_overview
  end

  def progress_tree
    authorize! :progress_tree, :progress_overview
    render json: progress_tree_json(current_project_id, params[:marker_id])
  end

  def export_progress_csv
    authorize! :export_progress_csv, :progress_overview

    marker = Marker.find(params[:marker_id]) if params[:marker_id]
    send_data(progress_table(current_project_id, params[:marker_id]),
              filename: "progress_status_#{marker.name}.csv",
              type: 'application/csv')
  end
end
