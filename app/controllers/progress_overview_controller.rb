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
