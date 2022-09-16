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

module IssuesHelper
  def has_unsolved_issues(record)
    record.issues.where(solved: false).present?
  end

  def issue_warning_color(record)
    "color: #{has_unsolved_issues(record) ? 'red' : 'grey'}"
  end

  def issues(record)
    html = +''.html_safe

    if record
      record.issues.order(:solved).order(created_at: :desc).each do |issue|
        if issue.solved
          begin
            user = User.find(issue.solved_by).name
          rescue ActiveRecord::RecordNotFound
            user = 'unknown user'
          end
          user_date = "Solved by #{user} on #{issue.solved_at.in_time_zone('CET').strftime('%Y-%m-%d')} (".html_safe
          solved_by = user_date + link_to('Mark as unsolved', solve_issue_path(issue)) + ")"
        else
          solved = content_tag(:span, '', class: %w(glyphicon glyphicon-exclamation-sign), style: 'color: red;')
          solved_by = link_to('Mark issue as solved', solve_issue_path(issue))
        end

        solved ||= ''

        html << content_tag(:tr) do
          content_tag(:td, solved, style: 'text-align: center') +
          content_tag(:td, issue.title) +
          content_tag(:td, issue.description) +
          content_tag(:td, issue.created_at) +
          content_tag(:td, solved_by)
        end
      end
    end

    html
  end
end