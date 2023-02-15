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

class MislabelsController < ApplicationController
  load_and_authorize_resource

  before_action :set_mislabel, only: :solve

  def solve
    if @mislabel.solved_by || @mislabel.solved
      @mislabel.update(solved_by: nil, solved_at: nil, solved: false)
      redirect_back(fallback_location: marker_sequences_path, warning: 'Mislabel warning marked as unsolved.')
    else
      @mislabel.update(solved_by: current_user.id, solved_at: Time.now, solved: true)
      redirect_back(fallback_location: marker_sequences_path, notice: 'Mislabel warning marked as solved.')
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mislabel
    @mislabel = Mislabel.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mislabel_params
    params.require(:mislabel).permit(:solved, :solved_by, :solved_at)
  end
end
