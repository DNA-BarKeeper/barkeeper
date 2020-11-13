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
  desc 'get_aligned_peak_indices'

  task get_aligned_peak_indices: :environment do
    total = PrimerRead.use_for_assembly.where(aligned_peak_indices: nil).count

    ctr = 0
    PrimerRead.use_for_assembly.where(aligned_peak_indices: nil).select(:id, :trimmedReadStart, :aligned_qualities, :aligned_peak_indices, :peak_indices).find_in_batches(batch_size: 100) do |batch|
      batch.each do |pr|
        ctr += 1
        puts "#{ctr} / #{total}"
        pr.get_aligned_peak_indices
      end
    end

    puts 'Done.'
  end
end
