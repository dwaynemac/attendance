HYDRA = Typhoeus::Hydra.new

if Rails.env == 'development'
	CONFIG = YAML.load_file("#{Rails.root}/config/padma_api.yml")
else
	CONFIG = {}
end

module Accounts
  API_KEY = ENV['accounts_key'] || CONFIG['accounts_key']
  if ENV['C9_USER']
    HOST = APP_CONFIG['accounts-url'].gsub("http://",'')
  end
end

module Contacts
  API_KEY = ENV['contacts_key'] || CONFIG['contacts_key']
  if ENV['C9_USER']
    HOST = APP_CONFIG['contacts-url'].gsub("http://",'')
  end
end

module ActivityStream
  API_KEY = ENV['activities_key'] || CONFIG['activities_key']
  LOCAL_APP_NAME = 'attendance'
  if ENV['C9_USER']
    HOST = APP_CONFIG['activity-stream-url'].gsub("https://",'')
  end
end


module Messaging
  HYDRA = ::HYDRA
  API_KEY = ENV['messaging_key'] || CONFIG['messaging_key']
end
