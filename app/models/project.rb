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

# frozen_string_literal: true

class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :contig_searches, dependent: :nullify
  has_many :marker_sequence_searches, dependent: :nullify
  has_many :individual_searches, dependent: :nullify

  has_and_belongs_to_many :primers
  has_and_belongs_to_many :markers

  has_and_belongs_to_many :isolates
  has_and_belongs_to_many :primer_reads
  has_and_belongs_to_many :contigs
  has_and_belongs_to_many :marker_sequences

  has_and_belongs_to_many :individuals
  has_and_belongs_to_many :taxa

  has_and_belongs_to_many :labs
  has_and_belongs_to_many :freezers
  has_and_belongs_to_many :shelves
  has_and_belongs_to_many :lab_racks
  has_and_belongs_to_many :micronic_plates
  has_and_belongs_to_many :plant_plates

  has_and_belongs_to_many :ngs_runs
  has_and_belongs_to_many :clusters

  validates_presence_of :name

  def add_project_to_taxonomy(parent_taxon_id)
    parent_taxon = Taxon.find(parent_taxon_id) if parent_taxon_id
    if parent_taxon
      parent_taxon.subtree.includes(:projects).each do |taxon|
        taxon.add_project_and_save(id)
      end
    end
  end
end
