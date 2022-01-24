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

require 'rails_helper'

RSpec.describe IndividualSearch do
  subject { FactoryBot.create(:individual_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to one user" do
    should belong_to(:user)
  end

  it "belongs to one project" do
    should belong_to(:project)
  end

  it "is not valid with a duplicate title" do
    should validate_uniqueness_of(:title).scoped_to(:user_id)
  end

  xit "finds records in database"
end