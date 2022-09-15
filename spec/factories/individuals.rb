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

require 'faker'

FactoryBot.define do
  factory :individual do |i|
    i.collected { Faker::Time.backward(days: 176) }
    i.collector { Faker::Name.name_with_middle }
    i.collectors_field_number { Faker::Lorem.word }
    i.comments { Faker::Lorem.paragraph }
    i.confirmation { Faker::Lorem.word }
    i.country { Faker::Address.country }
    i.determination { Faker::Lorem.word }
    i.DNA_bank_id { Faker::Space.galaxy }
    i.elevation { Faker::Lorem.word }
    i.exposition { Faker::Lorem.word }
    i.habitat { Faker::Lorem.sentence }
    i.has_issue { Faker::Boolean.boolean }
    i.latitude { Faker::Address.latitude }
    i.latitude_original { Faker::Address.latitude.to_s }
    i.longitude { Faker::Address.longitude }
    i.life_form { Faker::Lorem.word }
    i.locality { Faker::Lorem.paragraph }
    i.longitude_original { Faker::Address.longitude.to_s }
    i.revision { Faker::Lorem.word }
    i.silica_gel { Faker::Boolean.boolean }
    i.specimen_id { Faker::Space.constellation }
    i.state_province { Faker::Address.state }
    i.substrate { Faker::Lorem.word }

    factory :individual_with_taxonomy do
      association :species, factory: :species_with_taxonomy
    end

    factory :individual_with_isolates do
      transient do
        isolate_count { 10 }
      end

      after(:create) do |individual, evaluator|
        create_list(:isolate, evaluator.isolate_count, individual: individual)
      end
    end
  end
end