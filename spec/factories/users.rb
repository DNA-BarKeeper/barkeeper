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
  factory :user do |u|
    u.default_project_id { 1 }
    u.email { Faker::Internet.email }
    u.name { Faker::Name.name }
    u.password { Faker::Internet.password }
    u.role { 'user' }
    u.projects { [FactoryBot.create(:project, name: 'All')] }

    factory :admin do
      after(:create) do
        create(:user, role: 'admin')
      end
    end

    factory :guest do
      after(:create) do
        create(:user, role: 'guest')
      end
    end

    factory :supervisor do
      after(:create) do
        create(:user, role: 'supervisor')
      end
    end
  end
end