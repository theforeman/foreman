# disable to avoid journald native gem in development setup
group :journald do
  gem 'logging-journald', '~> 1.0'
end
