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

module PrimerReadsHelper
  def render_primer_read_list(all_reads)
    all_reads.map do |primer_read|
      render primer_read
    end.join.html_safe
  end

  def seq_for_display(read)
    (read.sequence[0..30]...read.sequence[-30..-1]).to_s if read.sequence.present?
  end

  def trimmed_seq_for_display(read)
    (read.sequence[read.trimmedReadStart..read.trimmedReadStart + 30]...read.sequence[read.trimmedReadEnd - 30..read.trimmedReadEnd]).to_s if read.sequence.present?
  end

  def name_for_display(read)
    if read.name.length > 25
      (read.name[0..11]...read.name[-11..-5]).to_s
    else
      read.name[0..-5].to_s
    end
  end
end
