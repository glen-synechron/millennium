# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#puts 'CREATING Categories'
#Category.create!([
#  { name: 'Hair' },
#  { name: 'Face' },
#  { name: 'Nails' }
#], without_protection: true)
#puts 'SETTING UP Sub categories'
#SubCategory.create! name: 'Hair Cut', category_id: 1
#SubCategory.create! name: 'Hair Colouring', category_id: 1
#SubCategory.create! name: 'Facial', category_id: 2
#SubCategory.create! name: 'Eye-brows', category_id: 2
#SubCategory.create! name: 'Nail Painting', category_id: 3
#SubCategory.create! name: 'Nail Removal', category_id: 3

if Salon.first.blank?
  Salon.create!(server: 'ec2-23-22-112-83.compute-1.amazonaws.com', 
    user: 'sdktest', password: 'sdk1234*', guid: "2282590F-B094-7FA1-5132-51667C35D70E",
    session_id: '234234242')
end
