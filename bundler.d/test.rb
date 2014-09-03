group :test do
  gem 'mocha', :require => false
  unless RUBY_VERSION =~ /^1\.8/
    gem 'simplecov'
    gem 'spork-minitest'
  end
  gem 'single_test'
  gem 'minitest', '~> 4.7'
  gem 'minitest-spec-rails'
  gem 'minitest-spec-rails-tu-shim', :platforms => :ruby_18
  gem 'ci_reporter', '>= 1.6.3', "< 2.0.0", :require => false
  gem 'capybara', '~> 2.0.0'
  # pinned for Ruby 1.8, selenium dependency
  gem 'rubyzip', '~> 0.9'
  gem 'database_cleaner', '0.9.1'
  gem 'launchy'
  gem 'spork'
  gem 'factory_girl_rails', '~> 1.2', :require => false
  gem 'oj'
  if RUBY_VERSION =~ /^1\.9|^2/
    gem 'rubocop-checkstyle_formatter'
  end
end
