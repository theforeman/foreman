group :mysql2 do
  # Matches gem requirement specified in ActiveRecord connection adapter
  gem 'mysql2', (SETTINGS[:rails] == '4.2' ? '>= 0.3.13' : '>= 0.3.18'), '< 0.5'
end
