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
  factory :marker_sequence_search do |ms|
    ms.has_taxon { Faker::Boolean.boolean }
    ms.has_warnings { Faker::Number.between(from: 0, to: 2) }
    ms.marker { Faker::Lorem.word }    
    ms.max_age { Faker::Time.backward(days: 176) }
    ms.max_length { Faker::Number.between(from: 2500, to: 5000) }
    ms.max_update { Faker::Time.backward(days: 176) }
    ms.min_age { Faker::Time.backward(days: 1) }
    ms.min_length { Faker::Number.between(from: 0, to: 2500) }
    ms.min_update { Faker::Time.backward(days: 1) }
    ms.name { Faker::Lorem.word }
    ms.no_isolate { Faker::Boolean.boolean }
    ms.taxon { Faker::Lorem.word }
    ms.specimen { Faker::Lorem.word }
    ms.title { Faker::GreekPhilosophers.name }
    ms.verified { ["verified", "unverified", "both"].sample }
    ms.verified_by { Faker::Name.name }
  end
end