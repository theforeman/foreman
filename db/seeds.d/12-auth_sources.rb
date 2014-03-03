AuthSource.without_auditing do
  # Auth sources
  src = AuthSourceInternal.find_by_type "AuthSourceInternal"
  src ||= AuthSourceInternal.create :name => "Internal"

  # Users
  unless User.find_by_login("admin").present?
    User.without_auditing do
      user = User.new(:login => "admin", :firstname => "Admin", :lastname => "User", :mail => Setting[:administrator])
      user.admin = true
      user.auth_source = src
      user.password = "changeme"
      User.current = user
      raise "Unable to create admin user: #{format_errors user}" unless user.save
    end
  end
end
