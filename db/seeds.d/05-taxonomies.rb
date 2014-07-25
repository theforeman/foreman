# Create an initial organization if specified
if SETTINGS[:organizations_enabled] && ENV['SEED_ORGANIZATION']
  Organization.without_auditing do
    Organization.find_or_create_by_name(:name => ENV['SEED_ORGANIZATION'])
  end
end

# Create an initial location if specified
if SETTINGS[:locations_enabled] && ENV['SEED_LOCATION']
  Location.without_auditing do
    Location.find_or_create_by_name(:name => ENV['SEED_LOCATION'])
  end
end
