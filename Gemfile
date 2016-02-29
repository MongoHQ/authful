source 'https://rubygems.org'

gem 'rails', '4.2.5'
gem 'grape'
gem 'rack-ssl-enforcer'

gem 'mongoid', '~> 4.0.2'
gem 'bson_ext'

gem 'twilio-ruby', '>= 3.11.4'
gem 'phonelib'
gem 'rotp'
gem 'rqrcode_png'

gem "bugsnag"

# Use unicorn as the app server
group :production do
  gem 'unicorn'
end

group :test, :development do
  gem 'byebug'
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers'
  gem 'test-unit'
end
