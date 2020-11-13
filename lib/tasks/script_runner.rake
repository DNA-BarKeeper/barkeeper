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
  task run_python: :environment do
    file = Rails.root.join('lib', 'sativa_test_files', 'python_test.py')
    output = `python #{file}`
    puts output
  end

  desc 'Runs a SATIVA mislabel analysis'
  task run_sativa: :environment do
    # SATIVA only understands relative file paths and has to be called inside the directory with the analysis data
    analysis_dir = Rails.root.join('lib', 'sativa_test_files')
    alignment_file = 'gbol5_caryophyllales_ITS_aligned.fasta'
    tax_file = 'gbol5_caryophyllales_ITS.tax'

    Dir.chdir(analysis_dir) do
      `python /home/sarah/SATIVA/sativa/sativa.py -s #{alignment_file} -t #{tax_file} -x BOT`
    end
  end
end
