group :assets do
  gem 'jquery-ui-rails', '< 5.0.0'
  gem 'patternfly-sass', '>= 3.32.1', '< 3.38.0'
  gem 'gettext_i18n_rails_js', '~> 1.0'
  gem 'execjs', '>= 1.4.0', '< 3.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails', '>= 5.0', ((RUBY_VERSION < '2.4') ? '< 5.0.8' : '< 6.0')
end
