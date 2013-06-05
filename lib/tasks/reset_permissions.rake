namespace :permissions do
  desc 'Reset Administrator user permissions to defaults'
  task :reset => :environment do
    unless Facter.domain.nil?
      user = User.find_or_create_by_login(:login => "admin", :firstname => "Admin", :lastname => "User", :mail => "root@#{Facter.domain}")
      user.update_attribute :admin, true
      src  = AuthSourceInternal.find_or_create_by_type "AuthSourceInternal"
      src.update_attribute :name, "Internal"
      user.auth_source = src
      user.password="changeme"
      if user.save
        puts "Reset to user:admin, password:changeme"
      else
        puts user.errors.full_messages.join(", ")
      end
    else
      fail "The domain of this host is not set."
    end
  end
end
