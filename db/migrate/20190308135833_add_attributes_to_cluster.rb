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
