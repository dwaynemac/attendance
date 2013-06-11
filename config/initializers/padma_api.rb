HYDRA = Typhoeus::Hydra.new

if Rails.env == 'development'
	CONFIG = YAML.load_file("#{Rails.root}/config/padma_api.yml")
else
	CONFIG = {}
end

module Accounts
  API_KEY = ENV['accounts_key'] || CONFIG['accounts_key']
end

module Contacts
  API_KEY = ENV['contacts_key'] || CONFIG['contacts_key']
end

module ActivityStream
  API_KEY = ENV['activities_key'] || CONFIG['activities_key']
  LOCAL_APP_NAME = 'attendance'
end