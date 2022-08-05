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
  factory :individual_search do |is|
    is.DNA_bank_id { Faker::Lorem.word }
    is.has_issue { Faker::Number.between(from: 0, to: 2) }
    is.has_problematic_location { Faker::Number.between(from: 0, to: 2) }
    is.has_taxon { Faker::Number.between(from: 0, to: 2) }
    is.collection { Faker::Lorem.word }
    is.taxon { Faker::Lorem.word }
    is.title { Faker::Lorem.word }
  end
end