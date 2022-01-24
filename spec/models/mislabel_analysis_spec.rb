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

RSpec.describe MislabelAnalysis do
  subject { FactoryBot.create(:mislabel_analysis) }

  it "is valid with valid attributes" do
    should be_valid
  end

  it "belongs to a marker" do
    should belong_to(:marker)
  end

  it "has one marker sequence search" do
    should have_one(:marker_sequence_search).dependent(:destroy)
  end

  it "has many mislabels" do
    should have_many(:mislabels).dependent(:destroy)
  end

  it "has and belongs to many marker sequences" do
    should have_and_belong_to_many(:marker_sequences)
  end

  context "calculates the relative amount of mislabels" do
    it "returns percentage for positive sequence count" do
      5.times { FactoryBot.create(:mislabel, mislabel_analysis: subject ) }
      subject.total_seq_number = 10
      expect(subject.percentage_of_mislabels).to be == 50.00
    end

    it "returns nil for negative sequence count" do
      5.times { FactoryBot.create(:mislabel, mislabel_analysis: subject ) }
      subject.total_seq_number = -1
      expect(subject.percentage_of_mislabels).to be == nil
    end
  end

  xit "other methods"
end