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

namespace :data do
  task flag_specimen: :environment do
    individual_ids = Individual.joins(isolates: :marker_sequences).distinct.merge(MarkerSequence.unsolved_warnings).pluck(:id)
    individuals_with_issues = []

    individual_ids.each do |individual_id|
      sequences = MarkerSequence.joins(isolate: :individual).distinct.unsolved_warnings.where('individuals.id = ?', individual_id)
      individuals_with_issues << individual_id if sequences.size > 1
    end

    individuals_with_issues.each do |individual_id|
      Individual.find(individual_id).update(has_issue: true)
    end
  end

  task unflag_specimen: :environment do
    individuals_with_flag = Individual.where(has_issue: true)

    individuals_with_flag.each do |individual|
      sequences = MarkerSequence.joins(isolate: :individual).distinct.unsolved_warnings.where('individuals.id = ?', individual.id)
      individual.update(has_issue: false) if sequences.size < 2
    end
  end
end
