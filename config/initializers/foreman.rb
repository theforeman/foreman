require 'foreman'

# We load the default settings if they are not already present
Foreman::DefaultSettings::Loader.load

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
