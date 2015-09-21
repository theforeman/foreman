# Create an initial organization if specified
if SETTINGS[:organizations_enabled] && ENV['SEED_ORGANIZATION'] && !Organization.any?
  Organization.without_auditing do
    User.current = User.anonymous_admin
    Organization.where(:name => ENV['SEED_ORGANIZATION']).first_or_create
    User.current = nil
  end
end

# Create an initial location if specified
if SETTINGS[:locations_enabled] && ENV['SEED_LOCATION'] && !Location.any?
  Location.without_auditing do
    User.current = User.anonymous_admin
    Location.where(:name => ENV['SEED_LOCATION']).first_or_create!
    User.current = nil
  end
end
