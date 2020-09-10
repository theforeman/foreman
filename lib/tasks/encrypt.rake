require_dependency 'foreman/util'

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
  ENCRYPTION_KEY = '#{secure_encryption_key}'
end
")
      puts "Encryption key generated in file config/initializers/encryption_key.rb"
      puts "Restart the server and then run rake db:compute_resources:encrypt"
    end
  end
end

namespace :db do
  def modify_encryptable_fields(klass, action)
    klass.order(:id).each do |encryptable_resource|
      encryptable_resource.encryptable_fields.each do |field|
        str = encryptable_resource.read_attribute(field.to_sym)
        encryptable_resource.update_column(field.to_sym,
          encryptable_resource.send("#{action}_field", str))
      end
    end
  end

  desc <<~END_DESC
    Encrypt all passwords (compute resources, LDAP authentication sources) using
    the encryption key in config/initializers/encryption_key.rb.

    Plugins might enhance this task.

    This task is idempotent and it will just skip already encrypted passwords.
  END_DESC
  task :encrypt_all do
    Rake::Task['db:auth_sources_ldap:encrypt'].invoke
    Rake::Task['db:compute_resources:encrypt'].invoke
  end

  desc <<~END_DESC
    Decrypt all passwords (compute resources, LDAP authentication sources) using the encryption key
    in config/initializers/encryption_key.rb.

    Plugins might enhance this task.

    This task is idempotent and it will just skip already decrypted passwords.
  END_DESC
  task :decrypt_all do
    Rake::Task['db:auth_sources_ldap:decrypt'].invoke
    Rake::Task['db:compute_resources:decrypt'].invoke
  end

  namespace :auth_sources_ldap do
    desc "Encrypt LDAP authentication source fields"
    task :encrypt => :environment do
      modify_encryptable_fields(AuthSourceLdap, :encrypt)
    end

    desc "Decrypt LDAP authentication source fields"
    task :decrypt => :environment do
      modify_encryptable_fields(AuthSourceLdap, :decrypt)
    end
  end

  namespace :compute_resources do
    desc "Encrypt compute resource fields"
    task :encrypt => :environment do
      modify_encryptable_fields(ComputeResource, :encrypt)
    end

    desc "Decrypt compute resource fields"
    task :decrypt => :environment do
      modify_encryptable_fields(ComputeResource, :decrypt)
    end
  end
end
