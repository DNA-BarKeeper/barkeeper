# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# user = CreateAdminService.new.call
# puts +'CREATED ADMIN USER: ' << user.email

project = Project.create!(name: 'All')
User.create!(name: 'Admin', email: 'admin@test.com', password: 'password', role: 'admin', projects: [project])