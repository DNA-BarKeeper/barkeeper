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
  factory :primer do |p|
    p.name { Faker::Lorem.word }
    p.alt_name { Faker::Lorem.word }
    p.author { Faker::Name.name }
    p.labcode { Faker::Lorem.characters(number: 6) }
    p.notes { Faker::Lorem.sentence }
    p.position { Faker::Number.within(range: 1..200) }
    p.reverse { Faker::Boolean.boolean }
    p.sequence(:sequence) { Faker::Lorem.characters(number: 25, min_alpha: 25) } # Sequence is a reserved word attribute
    p.target_group { Faker::Lorem.word }
    p.tm { Faker::Lorem.word }

    factory :primer_with_marker do
      association :marker, factory: :marker
    end
  end
end