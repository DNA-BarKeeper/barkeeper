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
namespace :data do
  task add_herbaria: :environment do
    stuttgart = Herbarium.find_or_create_by(name: 'Staatliches Museum für Naturkunde Stuttgart', acronym: 'STU')
    berlin = Herbarium.find_or_create_by(name: 'Herbarium Berolinense', acronym: 'B')
    munich = Herbarium.find_or_create_by(name: 'Botanische Staatssammlung München', acronym: 'M')
    bonn = Herbarium.find_or_create_by(name: 'University of Bonn', acronym: 'BONN')
    goettingen = Herbarium.find_or_create_by(name: 'Universität Göttingen', acronym: 'GOET')
    zuerich = Herbarium.find_or_create_by(name: 'Universität Zürich', acronym: 'Z')

    Individual.where(herbarium_code: 'STU').update_all(herbarium_id: stuttgart.id)
    Individual.where(herbarium_code: 'SMNS').update_all(herbarium_id: stuttgart.id)
    Individual.where(herbarium_code: 'B').update_all(herbarium_id: berlin.id)
    Individual.where(herbarium_code: 'BONN').update_all(herbarium_id: bonn.id)
    Individual.where(herbarium_code: 'M').update_all(herbarium_id: munich.id)
    Individual.where(herbarium_code: 'GOET').update_all(herbarium_id: goettingen.id)
    Individual.where(herbarium_code: 'Z').update_all(herbarium_id: zuerich.id)
  end
end