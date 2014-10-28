# Be sure to restart your server when you modify this file.

Assistance::Application.config.session_store :active_record_store

# needed for activerecord-session_store in rails 4.0.0
ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id
