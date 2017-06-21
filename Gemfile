source 'https://rubygems.org'
ruby '2.3.4'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.1.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'carrierwave', '0.10.0'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'carrierwave-aws', '1.0.2'
gem 'mini_magick'
gem 'jwt'
gem 'mongoid', git: 'https://github.com/mongodb/mongoid.git'
# gem 'mongoid-geospatial', git: "https://github.com/tedma4/mongoid-geospatial", require: 'mongoid/geospatial'
# gem 'rgeo', '0.5.3'
gem 'faker', '1.7.3'
gem 'figaro'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry-rails'
  gem 'pry-byebug'
end

group :development do
  gem 'redis', '~> 3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production do
	gem 'rails_12factor'
  gem 'redis', '~> 3.0'
end
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
