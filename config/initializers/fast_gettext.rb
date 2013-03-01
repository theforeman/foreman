require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(File.dirname(__FILE__), '..', '..', 'locale')

FastGettext.add_text_domain 'app', :path => locale_dir, :type => :po
FastGettext.default_available_locales = ['en','ja'] #all you want to allow
FastGettext.default_text_domain = 'app'
