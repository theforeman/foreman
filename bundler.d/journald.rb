# disable to avoid journald native gem in development setup
group :journald do
  gem 'logging-journald', '~> 2.0', :require => false
end
