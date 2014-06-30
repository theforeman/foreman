require 'facter'
namespace :permissions do
  desc 'Create or reset "admin" user permissions to defaults'
  task :reset => :environment do
    User.as_anonymous_admin do
      user = User.find_or_create_by_login(:login => ENV["username"] || 'admin', :firstname => 'Admin', :lastname => 'User', :mail => Setting[:administrator])
      src  = AuthSourceInternal.find_or_create_by_type "AuthSourceInternal"
      src.update_attribute :name, "Internal"
      user.admin = true
      user.auth_source = src
      random = User.random_password
      user.password = random
      if user.save
        puts "Reset to user: #{user.login}, password: #{random}"
      else
        puts user.errors.full_messages.join(", ")
      end
    end
  end
end
