group :assets do
  gem 'sass-rails' #, '~> 3.2'
  gem 'uglifier', '>= 1.0.3'
  gem 'execjs', '>= 1.4.0', '<2.5.0'
  gem 'jquery-rails', '2.0.3'
  gem 'jquery-ui-rails', '< 5.0.0'
  gem 'therubyracer', '0.11.3', :require => 'v8'
  gem 'bootstrap-sass', '3.0.3.0'
  gem 'spice-html5-rails', github: "isratrade/spice-html5-rails"
  gem 'flot-rails', '0.0.3'
  gem 'quiet_assets', '~> 1.0'
  gem 'gettext_i18n_rails_js', github: "juanboca/gettext_i18n_rails_js"
  # unspecified dep of gettext_i18n_rails_js
  #   https://github.com/nubis/gettext_i18n_rails_js/pull/23
  gem 'gettext', '~> 3.1', :require => false
  gem 'multi-select-rails', '~> 0.9'
  gem 'jquery-turbolinks', '~> 2.1'
  gem 'select2-rails', '~> 3.5'
  gem 'gridster-rails', github: "hampei/gridster-rails", branch: "rails4"
  gem 'jquery_pwstrength_bootstrap', github: "unorthodoxgeek/jquery_pwstrength_bootstrap-gem"
end
