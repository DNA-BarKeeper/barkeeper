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
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :contig_search do |cs|
    cs.assembled { ["assembled", "unassembled", "both"].sample }
    cs.family { Faker::Lorem.word }
    cs.has_warnings { ContigSearch.has_warnings.keys.sample }
    cs.marker { Faker::Lorem.word }
    cs.max_age { Faker::Time.backward(days: 176) }
    cs.max_update { Faker::Time.backward(days: 176) }
    cs.min_age { Faker::Time.backward(days: 1) }
    cs.min_update { Faker::Time.backward(days: 1) }
    cs.name { Faker::Lorem.word }
    cs.order { Faker::Lorem.word }
    cs.species { Faker::Lorem.word }
    cs.specimen { Faker::Lorem.word }
    cs.title { Faker::Lorem.word }
    cs.verified { ["verified", "unverified", "both"].sample }
    cs.verified_by { Faker::Name.name }

    factory :contig_search_valid_attachment do
      after(:create) do
        attachment = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'search_results.zip'), 'application/zip')
        create(:contig_search, search_result_archive: attachment)
      end
    end
  end
end