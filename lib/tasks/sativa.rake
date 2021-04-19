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

namespace :data do

  desc 'Check how many sequences were created or updated since last analysis and redo analysis if necessary'
  task check_new_marker_sequences: :environment do
    # TODO: Do analyses for all existing projects (except all_records)
    Marker.gbol_marker.each do |marker|
      last_analysis = MislabelAnalysis.where(automatic: true, marker: marker).order(created_at: :desc).first
      count = -1

      puts "Checking if new sequences for marker #{marker.name} exist..."

      if last_analysis
        count = MarkerSequence.where(marker_id: marker.id).where('marker_sequences.updated_at >= ?', last_analysis.created_at).size
      end

      if (count > 50) || (count == -1) # More than 50 new seqs OR no analysis was done before
        marker_name = marker.name
        search = MarkerSequenceSearch.create(has_species: true, has_warnings: 'both', marker: marker_name, project_id: 5)

        title = "all_taxa_#{marker_name}_#{search.created_at.to_date}"
        mislabel_analysis = MislabelAnalysis.create(title: title,
                                                    automatic: true,
                                                    total_seq_number: search.marker_sequences.size,
                                                    marker: marker,
                                                    marker_sequence_search: search)

        puts 'Starting analysis on external server...'
        mislabel_analysis.analyse_on_server
      else
        puts 'Nothing to analyse.'
      end
    end

    puts 'Finished successfully.'
  end
end
