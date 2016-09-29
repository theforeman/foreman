group :postgresql do
  # Matches gem requirement specified in ActiveRecord connection adapter
  gem 'pg', (SETTINGS[:rails] == '4.2' ? '~> 0.15' : '~> 0.18')
end
