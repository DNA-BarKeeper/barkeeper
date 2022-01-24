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

# Worker that processes uploaded pherograms
class PherogramProcessing
  include Sidekiq::Worker

  sidekiq_options queue: :pherogram_processing

  # Assigns the primer read specified by +primer_read_id+ to an isolate and a
  # primer and then trims it. Processed primer reads get the comment 'imported'.
  def perform(primer_read_id)
    primer_read = PrimerRead.find(primer_read_id)
    begin
      primer_read.auto_assign # Ensures that the read sequence gets reverse-complemented when the primer is reverse oriented
      primer_read.auto_trim(true)
    rescue StandardError
    end
    primer_read.update(processed: true, used_for_con: true, assembled: false, comment: 'imported')
  end
end
