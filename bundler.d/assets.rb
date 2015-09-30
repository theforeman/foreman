group :assets do
  gem 'ace-rails-ap', '~> 4.0.0'
  gem 'sass-rails'
  gem 'uglifier', '>= 1.0.3'
  gem 'execjs', '>= 1.4.0', '<2.5.0'
  gem 'jquery-rails', '2.0.3'
  gem 'jquery-ui-rails', '< 5.0.0'
  gem 'bootstrap-sass', '3.0.3.0'
  gem 'spice-html5-rails', '~> 0.1.5'
  gem 'flot-rails', '0.0.3'
  gem 'quiet_assets', '~> 1.0'
  gem 'gettext_i18n_rails_js', '~> 1.0.0'
  # unspecified dep of gettext_i18n_rails_js
  #   https://github.com/nubis/gettext_i18n_rails_js/pull/23
  gem 'gettext', '~> 3.1', :require => false
  gem 'multi-select-rails', '~> 0.9'
  gem 'gridster-rails', github: "hampei/gridster-rails", branch: "rails4" # TODO
  gem 'jquery_pwstrength_bootstrap', github: "unorthodoxgeek/jquery_pwstrength_bootstrap-gem" #TODO
  gem 'jquery-turbolinks', '~> 2.1'
  gem 'select2-rails', '~> 3.5'
  gem 'underscore-rails', '~> 1.8'
end
