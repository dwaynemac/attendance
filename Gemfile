source 'https://rubygems.org'

ruby "2.0.0"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0.rc1'

#Translations
gem 'i18n', '~> 0.6.6'
gem 'rails-i18n'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0.rc1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# Use twitter bootstrap as ui framework
gem 'less-rails-bootstrap', '~> 3.0.6'

# Javascript runtime for bootstrap's LESS files to compile to CSS.
gem 'therubyracer', :platforms => :ruby

gem 'angularjs-rails'

gem "select2-rails"

gem 'localeapp'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'figaro'

# Rails 4 support for Mass Assignment Security
gem 'protected_attributes'

# CAS authentication
gem 'devise', github: 'plataformatec/devise', :branch => 'rails4'
gem 'devise_cas_authenticatable'

# authorization
gem 'cancan'

# Padma Clients
gem 'activity_stream_client'
gem 'contacts_client', '~> 0.0.23'
gem 'accounts_client', '0.0.21'
gem 'messaging_client','~> 0.0.2'

gem 'carrierwave'
gem 'fog', github: 'fog/fog', ref: '272bc6b2a2769f8d1a8b50b1f6cd9741db4969b4' # TODO waiting release of version 1.20
gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem "workless"

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :test, :development do

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'database_cleaner'

  gem 'coveralls', require: false
end

gem 'validates_timeliness'

group :development do
  gem 'foreman'
  gem 'subcontractor', '0.6.1'

  gem 'byebug'
  #
  # for easier error debugging in development.
  gem 'better_errors'
  gem 'binding_of_caller'

  # documentation
  gem 'yard', '~> 0.8.3'
  gem 'yard-restful'
end

group :production do
  gem 'pg'
  gem 'rails_12factor'
  gem 'appsignal'
end
