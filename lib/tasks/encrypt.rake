require 'foreman/util'

namespace :security do
  desc 'Generate new encryption key'
  task :generate_encryption_key do
    include Foreman::Util
    File.open(Rails.root.join('config', 'initializers', 'encryption_key.rb'), "w") do |fd|
      fd.write("# Be sure to restart your server when you modify this file.

# Your encryption key for encrypting and decrypting database fields.
# If you change this key, all encrypted data will NOT be able to be decrypted by Foreman!
# Make sure the key is at least 32 bytes such as SecureRandom.hex(20)

# You can use `rake security:generate_encryption_key` to regenerate this file.

module EncryptionKey
  ENCRYPTION_KEY = ENV['ENCRYPTION_KEY'] || '#{secure_encryption_key}'
end
")
      puts "Encryption key generated in file config/initializers/local_encryption_key.rb"
      puts "Restart the server and then run rake db:compute_resources:encrypt"
    end
  end
end
