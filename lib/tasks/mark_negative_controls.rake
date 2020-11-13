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
# frozen_string_literal: true

namespace :data do
  desc "fill reads' basecount"

  task mark_negative_controls: :environment do
    controls = %w[
      GBoL96
      GBoL192
      GBoL288
      GBoL384
      GBoL480
      GBoL576
      GBoL672
      GBoL768
      GBoL864
      GBoL960
      GBoL1056
      GBoL1152
      GBoL1248
      GBoL1344
      GBoL1440
      GBoL1536
      GBoL1632
      GBoL1728
      GBoL1824
      GBoL1920
      GBoL2016
      GBoL2112
      GBoL2208
      GBoL2304
      GBoL2400
      GBoL2496
      GBoL2592
      GBoL2688
      GBoL2784
      GBoL2880
      GBoL2976
      GBoL3072
      GBoL3168
      GBoL3264
      GBoL3360
      GBoL3456
      GBoL3552
      GBoL3648
      GBoL3744
      GBoL3840
      GBoL3936
      GBoL4032
      GBoL4128
      GBoL4224
      GBoL4320
      GBoL4416
      GBoL4512
      GBoL4608
      GBoL4704
      GBoL4800
      GBoL4896
      GBoL4992
      GBoL5088
      GBoL5184
      GBoL5280
      GBoL5376
      GBoL5472
      GBoL5568
      GBoL5664
      GBoL5760
      GBoL5856
      GBoL5952
      GBoL6048
      GBoL6144
      GBoL6240
      GBoL6336
    ]

    controls.each do |c|
      isolate = Isolate.where(lab_isolation_nr: c).first
      isolate&.update(negative_control: true)
    end

    puts 'Done.'
  end
end
