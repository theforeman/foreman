# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Foreman_session',
  :secret      => '4fe1a103699cf36976181cb4d343e6cb27d7904113c9a2113862c53b51f12357f413c996e820e6e544464242915d643d32b698a9679bbfe63f6eedfd9bf67961'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
