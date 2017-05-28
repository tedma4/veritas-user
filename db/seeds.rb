# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# Rails.application.load_seed
require 'image_string'

def faker_title
 pick =[
  [Faker::Beer.name, Faker::TwinPeaks.quote],
  [Faker::Book.title, Faker::TwinPeaks.quote],
  [Faker::Cat.breed, Faker::TwinPeaks.quote],
  ["Chuck Norris", Faker::ChuckNorris.fact]].sample

 return {title: pick.first, message: pick.last}
end



	