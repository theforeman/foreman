require 'foreman'

# We may be executing something like rake db:migrate:reset, which destroys this table
# only continue if the table exists
if (Setting.table_exists? rescue(false))
  # in this phase, the classes are not fully loaded yet, load them
  Dir[File.join(Rails.root, "app/models/setting/*.rb")].each do |f|
    require_dependency(f)
  end

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
