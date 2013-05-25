HYDRA = Typhoeus::Hydra.new

CONFIG = YAML.load_file("#{Rails.root}/config/padma_api.yml")

module Accounts
  API_KEY = ENV['accounts_key'] || CONFIG['accounts_key']
end

module Contacts
  API_KEY = ENV['contacts_key3'] || CONFIG['contacts_key']
end