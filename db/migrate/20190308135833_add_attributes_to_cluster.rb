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

class AddAttributesToCluster < ActiveRecord::Migration[5.0]
  def change
    add_column :clusters, :sequence_count, :integer
    add_column :clusters, :fasta, :string
    add_column :clusters, :reverse_complement, :boolean

    add_reference :clusters, :isolate, index: true
    add_reference :clusters, :ngs_run, index: true
    add_reference :clusters, :marker, index: true

    add_reference :ngs_runs, :isolate, index: true
  end
end
