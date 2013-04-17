require 'foreman'

# We may be executing something like rake db:migrate:reset, which destroys this table
# only continue if the table exists
if (Setting.first rescue(false))
  # Avoid lazy-loading in development mode
  %w[General Puppet Auth Provisioning].each do |c|
    require_dependency Rails.root.join('app', 'models', 'setting', c.downcase).to_s
  end if Rails.env.development?

  Setting.descendants.each(&:load_defaults)
end

# We load the default settings for the roles if they are not already present
Foreman::DefaultData::Loader.load(false)

# clear our users topbar cache
begin
  User.unscoped.pluck(:id).each do |id|
    Rails.cache.delete("views/tabs_and_title_records-#{id}")
  end
rescue => e
  Rails.logger.warn e
end
