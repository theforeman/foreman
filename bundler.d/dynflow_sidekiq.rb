group :dynflow_sidekiq do
  gem 'sidekiq', '~> 5.0'
  gem 'gitlab-sidekiq-fetcher', require: false
  gem 'sd_notify', '~> 0.1'
end
