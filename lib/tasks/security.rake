require_dependency 'foreman/util'

namespace :security do
  desc 'Generate new security token'
  task :generate_token, [:path] do |t, args|
    include Foreman::Util
    path = args[:path] || Rails.root.join('config', 'initializers', 'local_secret_token.rb')
    File.open(path, "w") do |fd|
      fd.write("# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

# You can use `rake security:generate_token` to regenerate this file.

Foreman::Application.config.secret_key_base = '#{secure_token}'
")
    end
  end
end
