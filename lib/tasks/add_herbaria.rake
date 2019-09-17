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