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
  factory :ngs_result do |n|
    n.cluster_count { Faker::Number.within(range: 0..2000) }
    n.hq_sequences { Faker::Number.within(range: 0..2000) }
    n.incomplete_sequences { Faker::Number.within(range: 0..2000) }
    n.total_sequences { Faker::Number.within(range: 0..2000) }
  end
end
