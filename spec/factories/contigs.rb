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
  factory :contig do |c|
    c.allowed_mismatch_percent { Faker::Number.within(range: 1..100) }
    c.assembled { Faker::Boolean.boolean }
    c.assembly_tried { Faker::Boolean.boolean }
    c.comment { Faker::Lorem.sentence}
    c.consensus { Faker::Lorem.word }
    c.fas { Faker::Lorem.paragraph }
    c.imported { Faker::Boolean.boolean }
    c.name { Faker::Lorem.word }
    c.overlap_length { Faker::Number.within(range: 1..100)  }
    c.partial_cons_count { Faker::Number.within(range: 1..10) }
    c.verified { Faker::Boolean.boolean }
    c.verified_at { Faker::Time.backward(days: 176) }
    c.verified_by { Faker::Name.name_with_middle }

    factory :contig_with_taxonomy do
      association :isolate, factory: :isolate_with_taxonomy
    end

    factory :contig_with_primer_reads do
      transient do
        primer_reads_count { 4 }
      end

      after(:create) do |contig, evaluator|
        create_list(:primer_read, evaluator.primer_reads_count, contig: contig)
      end
    end
  end
end