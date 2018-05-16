# Create an initial organization if specified
if SETTINGS[:organizations_enabled] && ENV['SEED_ORGANIZATION'] && !Organization.any?
  Organization.without_auditing do
    original_user, User.current = User.current, User.anonymous_admin
    @organization = Organization.where(:name => ENV['SEED_ORGANIZATION']).first_or_create
    User.current = original_user
  end
end

# Create an initial location if specified
if SETTINGS[:locations_enabled] && ENV['SEED_LOCATION'] && !Location.any?
  Location.without_auditing do
    original_user, User.current = User.current, User.anonymous_admin
    @location = Location.where(:name => ENV['SEED_LOCATION']).first_or_create!
    User.current = original_user
  end
end

# Add the initial location to the initial organization to prevent mismatches
# when a host is created that uses them
if @organization && @location && @organization.locations.exclude?(@location)
  @organization.locations << @location
end
