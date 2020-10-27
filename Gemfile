source 'https://rubygems.org'

ruby "2.3.8"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.2'

gem 'rack-cors'

#Translations
gem 'i18n', '~> 0.6.6'
gem 'rails-i18n'

gem "intercom-rails"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0.rc1'

gem "sprockets", "2.12.5" # https://blog.heroku.com/rails-asset-pipeline-vulnerability
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.0.1'

# Use twitter bootstrap as ui framework
gem 'less-rails-bootstrap', '~> 3.0.6'
gem 'padma-assets', '0.2.29'
gem 'rails_serve_static_assets'

# Javascript runtime for bootstrap's LESS files to compile to CSS.
gem 'therubyracer', '0.12.2', :platforms => :ruby

gem 'angularjs-rails'
gem "select2-rails", '~> 4.0.0'

gem 'bootstrap-multiselect-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'figaro'

# CAS authentication
gem 'devise', '3.4.1' 
gem 'activerecord-session_store'

# authorization
gem 'cancan'

# Padma Clients
gem 'logical_model', '0.6.6'
gem 'activity_stream_client', '0.0.16'
gem 'contacts_client', '~> 0.0.54'
gem 'accounts_client', '0.2.38'
gem 'messaging_client','~> 0.2'

gem 'carrierwave'
gem 'fog', github: 'fog/fog', ref: '272bc6b2a2769f8d1a8b50b1f6cd9741db4969b4' # TODO waiting release of version 1.20
gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem "workless"

gem 'json', '1.8.6'
# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger

gem 'rake', '< 12'
gem 'pg', '~> 0.20'

group :test, :development do

  # Use sqlite3 as the database for Active Record
  gem 'sqlite3', '1.3.11'

  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'factory_girl_rails'
  gem 'database_cleaner'

  gem 'coveralls', require: false
end

gem 'validates_timeliness'
gem 'byebug', '~> 11.0.1'

group :development do
  gem 'foreman'
  #gem 'subcontractor', '0.6.1'

  #
  # for easier error debugging in development.
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'pry'

  # documentation
  gem 'yard', '~> 0.8.3'
  gem 'yard-restful'

  gem 'git-pivotal-tracker-integration'
end

gem 'appsignal', '~> 2.8'

group :production do
  gem 'rails_12factor'
  gem 'le' # logentries
end
