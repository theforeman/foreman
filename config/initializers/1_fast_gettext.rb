require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(Rails.root, 'locale')
locale_domain = 'foreman'

Foreman::Gettext::Support.register_available_locales locale_domain, locale_dir
Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir

FastGettext.default_text_domain = locale_domain
FastGettext.locale = "en"

Foreman::Gettext::Support.register_human_localenames

# work in all domains context by default (for plugins)
include FastGettext::TranslationMultidomain

# When mark_translated setting is set, we will wrap all translated strings
# which is useful when translating code base.
if SETTINGS[:mark_translated] and not Rails.env.test?
  include Foreman::Gettext::Debug
else
  include Foreman::Gettext::AllDomains
end
