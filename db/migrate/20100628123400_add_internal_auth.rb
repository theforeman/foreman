require 'facter'
class AddInternalAuth < ActiveRecord::Migration
  class User < ActiveRecord::Base
    attr_accessor :password
    before_validation :prepare_password

    def prepare_password
      unless password.blank?
        self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
        self.password_hash = encrypt_password(password)
      end
    end

    def encrypt_password(pass)
      Digest::SHA1.hexdigest([pass, password_salt].join)
    end
  end

  def self.up
    add_column :users, :password_hash, :string, :limit => 128
    add_column :users, :password_salt, :string, :limit => 128

    User.reset_column_information

    user = User.unscoped.find_or_create_by_login(:login => "admin", :firstname => "Admin", :lastname => "User", :mail => "root@#{Facter.domain}")
    user.admin = true
    src  = AuthSourceInternal.find_or_create_by_type "AuthSourceInternal"
    src.update_attribute :name, "Internal"
    user.auth_source_id = src.id
    user.password="changeme"
    if user.save
      say "****************************************************************************************"
      say "The newly created internal account named admin has been allocated a password of 'changeme'"
      say "Set this to something else in the settings/users page"
      say "****************************************************************************************"
    else
      say user.errors.full_messages.join(", ")
    end
  end

  def self.down
    if (auth = AuthSourceInternal.first)
      auth.users.each {|u| u.destroy}
      auth.destroy
    end
    remove_column :users, :password_salt
    remove_column :users, :password_hash
  end
end
