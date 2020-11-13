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
require Rails.root.join "spec/concerns/project_record_spec.rb"

RSpec.describe TagPrimerMap do
  before(:all) { Project.create(name: 'All') }
  it_behaves_like "project_record"

  subject { FactoryBot.create(:tag_primer_map) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to an NGS run" do
    should belong_to(:ngs_run)
  end

  it "sets a name after save" do
    should callback(:set_name).after(:save)
  end

  context "active record attachment" do
    it "validates presence of a tag primer map file" do
      is_expected.to validate_attached_of(:tag_primer_map)
    end

    it "validates content type of tag primer map file" do
      is_expected.to validate_content_type_of(:tag_primer_map)
                         .allowing('text/plain', 'text/csv')
    end

    it "is not valid without tag primer map file" do
      expect(FactoryBot.build(:tag_primer_map, tag_primer_map: nil)).to_not be_valid
    end
  end

  context "sets name to name of attached file" do
    it "sets the name to the correct value after save" do
      new_tpm = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'tagPrimerMap_2195B.txt'))
      subject.tag_primer_map.attach(io: File.open(new_tpm), filename: 'tagPrimerMap_2195B.txt', content_type: 'text/plain')
      subject.save

      expect(subject.name).to be == "2195B"
    end

    it "chooses correct part of file name if it contains additional info" do
      new_tpm = fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'tagPrimerMap_2195B_corrected.txt'))
      subject.tag_primer_map.attach(io: File.open(new_tpm), filename: 'tagPrimerMap_2195B_corrected.txt', content_type: 'text/plain')
      subject.save

      expect(subject.name).to be == "2195B"
    end
  end

  xit "does stuff with a tpm file"
end