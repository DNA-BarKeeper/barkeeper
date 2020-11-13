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

class PartialConsController < ApplicationController
  load_and_authorize_resource

  before_action :set_partial_con, only: %i[show_page show_position]

  def show_page
    respond_to do |format|
      format.json do
        render json: @partial_con.to_json_for_page(params[:page], params[:width_in_bases])
      end
    end
  end

  def show_position
    respond_to do |format|
      format.json do
        render json: @partial_con.to_json_for_position(params[:position], params[:width_in_bases])
      end
    end
  end

  private

  def set_partial_con
    @partial_con = PartialCon.includes(:primer_reads).find(params[:id])
  end

  def partial_con_params
    params.require(:partial_con).permit(:page, :position, :width_in_bases)
  end
end
