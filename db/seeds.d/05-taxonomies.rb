# Create an initial organization if specified
if SETTINGS[:organizations_enabled] && ENV['SEED_ORGANIZATION'] && !Organization.any?
  Organization.without_auditing do
    User.current = User.anonymous_admin
    org = Organization.find_or_create_by_name!(:name => ENV['SEED_ORGANIZATION'])
    Setting[:default_organization] = org.title if Setting[:default_organization].blank?
    User.current = nil
  end
end

# Create an initial location if specified
if SETTINGS[:locations_enabled] && ENV['SEED_LOCATION'] && !Location.any?
  Location.without_auditing do
    User.current = User.anonymous_admin
    loc = Location.find_or_create_by_name!(:name => ENV['SEED_LOCATION'])
    Setting[:default_location] = loc.title if Setting[:default_location].blank?
    User.current = nil
  end
end
