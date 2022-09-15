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
namespace :data do
  desc 'Update PgSearch Document table'
  task update_search_index: :environment do
    PgSearch::Multisearch.rebuild(Contig)
    PgSearch::Multisearch.rebuild(Freezer)
    PgSearch::Multisearch.rebuild(Collection)
    PgSearch::Multisearch.rebuild(Individual)
    PgSearch::Multisearch.rebuild(Isolate)
    PgSearch::Multisearch.rebuild(Lab)
    PgSearch::Multisearch.rebuild(LabRack)
    PgSearch::Multisearch.rebuild(Marker)
    PgSearch::Multisearch.rebuild(MicronicPlate)
    PgSearch::Multisearch.rebuild(NgsRun)
    PgSearch::Multisearch.rebuild(PlantPlate)
    PgSearch::Multisearch.rebuild(Primer)
    PgSearch::Multisearch.rebuild(PrimerRead)
    PgSearch::Multisearch.rebuild(Shelf)
    PgSearch::Multisearch.rebuild(Taxon)
    PgSearch::Multisearch.rebuild(Tissue)
  end
end
