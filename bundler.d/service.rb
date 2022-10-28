gem 'puma', '~> 5.1', groups: [:test, :service], require: false
group :service do
  # Puma has a soft dependency on this
  gem 'sd_notify', '~> 0.1.0'
end
