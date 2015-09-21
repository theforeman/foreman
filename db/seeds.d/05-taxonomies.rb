# Create an initial organization if specified
if SETTINGS[:organizations_enabled] && ENV['SEED_ORGANIZATION'] && !Organization.any?
  Organization.without_auditing do
    User.current = User.anonymous_admin
    Organization.find_or_create_by(:name => ENV['SEED_ORGANIZATION'])
    User.current = nil
  end
end

# Create an initial location if specified
if SETTINGS[:locations_enabled] && ENV['SEED_LOCATION'] && !Location.any?
  Location.without_auditing do
    User.current = User.anonymous_admin
    Location.find_or_create_by(:name => ENV['SEED_LOCATION'])
    User.current = nil
  end
end
