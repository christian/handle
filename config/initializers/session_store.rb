# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_haendel_session',
  :secret      => '4f2fc9f784eb8789989700c04fc17fc9dc03a72290c6aa6825ad145d034e188af29b68c39b4cd6d10a8891fc6732afa905ba6ba06c21e9710f2dc06eb337dff3'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
