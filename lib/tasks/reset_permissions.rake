require 'facter'
namespace :permissions do
  desc <<-END_DESC
Create or reset "admin" user permissions to defaults.  Alternatively, you may
specify a username or password.

Examples:
  # foreman-rake permissions:reset
  Reset to user: admin, password: HrbX7zQErrT6

  # foreman-rake permissions:reset username=bclark password=changeme
  Reset to user: bclark, password: changeme
END_DESC

  task :reset => :environment do
    User.as_anonymous_admin do
      user = User.find_or_create_by(:login => ENV["username"] || 'admin', :firstname => 'Admin', :lastname => 'User', :mail => Setting[:administrator])
      src  = AuthSourceInternal.find_or_create_by(:type => "AuthSourceInternal")
      src.update_attribute :name, "Internal"
      user.admin = true
      user.auth_source = src
      password = ENV["password"] || User.random_password
      user.password = password
      if user.save
        puts "Reset to user: #{user.login}, password: #{password}"
      else
        puts user.errors.full_messages.join(", ")
      end
    end
  end
end
