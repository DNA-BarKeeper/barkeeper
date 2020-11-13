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
  desc 'Check if chromatogram file is available on S3'
  task chromatogram_availability: :environment do
    log = File.open("chromatogram_availability_log.txt", 'w')

    cnt = 0
    PrimerRead.all.with_attached_chromatogram.find_each do |pr|
      begin
        pr.chromatogram.blob.download
        print '.'
      rescue Aws::S3::Errors::NoSuchKey
        cnt += 1
        print '!'
        log.puts(pr.name)
      end
    end

    log.puts("No chromatogram file could be found on S3 for #{cnt} primer reads.")
    puts "Finished."
  end
end
