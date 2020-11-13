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
  desc 'Compare contig consensus sequences and resulting marker sequences. Alert if different.'
  task check_consensus_sequences: :environment do
    puts 'Checking contig consensus sequences...'

    contigs = Contig.gbol.includes(:marker_sequence, :partial_cons).where.not(marker_sequence: nil).select(:id, :name, :marker_sequence_id)
    alert = []
    no_sequence = []
    ms_blank = []

    contigs.first(200).each do |contig|
      marker_sequence = contig.marker_sequence.sequence
      if marker_sequence.blank?
        ms_blank << contig.name
      else
        partial_sequence = contig.partial_cons.first&.aligned_sequence

        if partial_sequence.blank?
          no_sequence << contig.name
        else
          # Marker sequences are created from modified aligned_sequence of first partial con after verification
          partial_sequence = partial_sequence.delete('?').delete('-')

          alert << contig.name if marker_sequence != partial_sequence
        end
      end
    end

    puts "Done. Incongruities found for #{alert.size} contigs:"
    p alert

    puts "#{no_sequence.size} contigs had no consensus sequence."

    puts "#{ms_blank.size} contigs had no marker sequence."
  end
end
