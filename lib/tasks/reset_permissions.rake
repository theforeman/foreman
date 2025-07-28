namespace :permissions do
  desc <<~END_DESC
    Reset "admin" user permissions to defaults.  Alternatively, you may
    specify a username or password.

    Examples:
      # foreman-rake permissions:reset
      Reset to user: admin, password: HrbX7zQErrT6

      # foreman-rake permissions:reset username=bclark password=changeme
      Reset existing user: bclark, password: changeme
  END_DESC

  task :reset => :environment do
    User.as_anonymous_admin do
      username = ENV["username"] || 'admin'
      created = !User.exists?(login: username)

      user = User.where(:login => username).first_or_create(:firstname => 'Admin', :lastname => 'User', :mail => Setting[:administrator])
      src  = AuthSourceInternal.where(:type => "AuthSourceInternal").first_or_create
      src.update_attribute :name, "Internal"
      user.admin = true
      user.auth_source = src
      password = ENV["password"] || User.random_password
      user.password = password
      if user.save
        puts "#{created ? 'Created new user' : 'Reset to user'}: #{user.login}, password: #{password}"
        puts "WARNING: You need to change the password for hammer in ~/.hammer/cli.modules.d/foreman.yml manually!"
      else
        puts user.errors.full_messages.join(", ")
      end
    end
  end
end
