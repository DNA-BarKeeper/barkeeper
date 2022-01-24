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

module IndividualsHelper
  def habitat_for_display(individual)
    if individual.habitat.present? && (individual.habitat.length > 60)
      (individual.habitat[0..30]...individual.habitat[-30..-1]).to_s
    else
      individual.habitat
    end
  end

  def locality_for_display(individual)
    if individual.locality.present? && (individual.locality.length > 60)
      (individual.locality[0..30]...individual.locality[-30..-1]).to_s
    else
      individual.locality
    end
  end

  def comments_for_display(individual)
    if individual.comments.present? && (individual.comments.length > 60)
      (individual.comments[0..30]...individual.comments[-30..-1]).to_s
    else
      individual.comments
    end
  end
end
