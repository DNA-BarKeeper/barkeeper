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
class NgsRunMailer < ApplicationMailer
  default from: "notifications@#{ENV['PROJECT_DOMAIN']}"

  def request_submitted
    @user = params[:user]
    @ngs_run = params[:ngs_run]

    User.where(role: 'admin').each do |admin_user|
      mail(to: admin_user.email, subject: "NGS raw data analysis request by #{@user.name}") do |format|
        format.html
        format.text
      end
    end
  end
end
