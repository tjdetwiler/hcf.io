# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.delete_all
admin = User.create({:login=>"admin", :email=>"admin@hcf.io", :password=>"password", :password_confirmation=>"password"})
Project.delete_all
init_project = Project.create({})

