group :sqlite do
  gem 'sqlite3', ((SETTINGS[:rails] == '5.2') ? '~> 1.3.6' : '~> 1.4')
end
