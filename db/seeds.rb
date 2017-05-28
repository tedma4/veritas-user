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


require 'image_string'

user = User.new
	user.first_name = "Ted"
	user.last_name = "Martinez"
	user.user_name = "Teddybear"
	user.email = "ted@martinez.com"
	user.password = "password"
	user.avatar = ImageString.image_file
user.save

# user_params = { "user" => {"email" => "ted@martinez.com", "password" => "password"} }
# app.post('/sessions', user_params, {"authorization" => ENV['my_jwt']})

# user_params = { "user" => {"email" => "ted@martinez.com", "password" => "password"} }
# app.delete('/sessions', {}, {"authorization" => ENV['my_jwt']})