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
include ActionDispatch::TestProcess

FactoryBot.define do
  factory :primer_read do |p|
    p.comment { Faker::Lorem.sentence }
    p.name { "GBoL1000_cp148" }
    p.position { Faker::Number.within(range: 1..200) }
    p.window_size { Faker::Number.within(range: 1..20) }
    p.chromatogram { fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'GBoL1000_cp148.scf')) }
  end
end