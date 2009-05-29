# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_pixel_printer_session',
  :secret      => '4650a370ae7bf6c673e463936bd8f70f15af7d6bb4d9aca4e0ffab74700e0a7498dd0e95f30fb8acb46748a9f2b176bf47a4d4c25295b785a80acb48be58642c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
