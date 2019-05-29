# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

project = Project.create!(name: 'All')
user = CreateAdminService.new.call([project])

puts +'CREATED ADMIN USER: ' << user.email

records = JSON.parse(File.read('seeds.json'))
records.each do |record|
  ModelName.create!(record)
end

Contig.update_all(verified_by: user.id, verified_at: Time.now)