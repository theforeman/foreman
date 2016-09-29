# Users

src_internal = AuthSourceInternal.find_by_type "AuthSourceInternal"
src_hidden = AuthSourceHidden.find_by_type "AuthSourceHidden"

# Anonymous Admin is used for system actions like automatic user creation,
# maintenance tasks etc.
unless User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
  User.without_auditing do
    user = User.new(:login => User::ANONYMOUS_ADMIN, :firstname => "Anonymous", :lastname => "Admin")
    user.admin = true
    user.auth_source = src_hidden
    User.current = user
    raise "Unable to create anonymous admin user: #{format_errors user}" unless user.save
  end
end

# Anonymous API user is used for API access when oauth_map_users is disabled
# It should be removed and replaced by per-user OAuth tokens (#1301)
unless User.unscoped.find_by_login(User::ANONYMOUS_API_ADMIN).present?
  User.without_auditing do
    user = User.new(:login => User::ANONYMOUS_API_ADMIN, :firstname => "API", :lastname => "Admin")
    user.admin = true
    user.auth_source = src_hidden
    User.current = user
    raise "Unable to create anonymous API user: #{format_errors user}" unless user.save
  end
end

# First real admin user account
unless User.unscoped.only_admin.except_hidden.present?
  User.without_auditing do
    User.as_anonymous_admin do
      admin_user = ENV['SEED_ADMIN_USER'].present? ? ENV['SEED_ADMIN_USER'] : 'admin'
      user = User.new(:login     => admin_user,
                      :firstname => ENV['SEED_ADMIN_FIRST_NAME'] || "Admin",
                      :lastname  => ENV['SEED_ADMIN_LAST_NAME'] || "User",
                      :mail      => (ENV['SEED_ADMIN_EMAIL'] || Setting[:administrator]).dup)
      user.admin = true
      user.auth_source = src_internal
      if ENV['SEED_ADMIN_PASSWORD'].present?
        user.password = ENV['SEED_ADMIN_PASSWORD']
      else
        random = User.random_password
        user.password = random
        puts "Login credentials: #{user.login} / #{random}" unless Rails.env.test?
      end
      raise "Unable to create admin user: #{format_errors user}" unless user.save
    end
  end
end
