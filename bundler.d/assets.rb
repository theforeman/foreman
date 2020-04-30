group :assets do
  gem 'jquery-ui-rails', '~> 6.0'
  gem 'patternfly-sass', '~> 3.59.4'
  gem 'gettext_i18n_rails_js', '~> 1.0'
  gem 'execjs', '>= 1.4.0', '< 3.0'
  gem 'uglifier', '>= 1.0.3'
  gem 'sass-rails', '>= 5.0', '< 7.0'
  # this one is a dependecy for x-editable-rails
  case SETTINGS[:rails]
  when '5.2'
    gem 'coffee-rails', '~> 4.2.2'
  when '6.0'
    gem 'coffee-rails', '~> 5.0.0'
  end
end
