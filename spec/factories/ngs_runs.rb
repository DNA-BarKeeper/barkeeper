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
require 'faker'

FactoryBot.define do
  factory :ngs_run do |n|
    n.comment { Faker::Lorem.sentence }
    n.fastq_location { Faker::Lorem.word }
    n.name { Faker::Lorem.word }
    n.primer_mismatches { Faker::Number.within(range: 1..10) }
    n.quality_threshold { Faker::Number.within(range: 1..100) }
    n.sequences_filtered { Faker::Number.within(range: 1..100) }
    n.sequences_high_qual { Faker::Number.within(range: 1..100) }
    n.sequences_one_primer { Faker::Number.within(range: 1..100) }
    n.sequences_pre { Faker::Number.within(range: 1..100) }
    n.sequences_short { Faker::Number.within(range: 1..100) }
    n.tag_mismatches { Faker::Number.within(range: 1..10) }
  end
end