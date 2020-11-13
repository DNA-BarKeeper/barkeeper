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
require 'rails_helper'

RSpec.describe ContigSearch do
  subject { FactoryBot.create(:contig_search) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "has one user" do
    should belong_to(:user)
  end

  it "has one project" do
    should belong_to(:project)
  end

  context "active record attachment" do
    it "validates content type of search result archive" do
      is_expected.to validate_content_type_of(:search_result_archive)
                         .allowing('application/zip')
    end

    it "is valid with valid search result archive" do
      with_attachment = FactoryBot.create(:contig_search_valid_attachment)
      expect(with_attachment).to be_valid
    end

    it "is not valid with a duplicate title" do
      should validate_uniqueness_of(:title).scoped_to(:user_id)
    end
  end

  xit "finds records in database" do

  end

  context "create contig archive" do
    xit "creates a contig archive containing primer reads" do

    end
  end
end