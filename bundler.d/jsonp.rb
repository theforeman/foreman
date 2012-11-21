group :jsonp do
  gem 'rack-jsonp', :require => 'rack/jsonp' if SETTINGS[:support_jsonp]
end
