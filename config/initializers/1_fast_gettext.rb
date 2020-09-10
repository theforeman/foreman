require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(Rails.root, 'locale')
locale_domain = 'foreman'

Foreman::Gettext::Support.register_available_locales locale_domain, locale_dir
Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir

I18n.config.enforce_available_locales = false
I18n.config.available_locales = FastGettext.default_available_locales.map { |loc| loc.tr('_', '-') }
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)

FastGettext.default_text_domain = locale_domain
FastGettext.default_locale = "en"
FastGettext.locale = "en"

Foreman::Gettext::Support.register_human_localenames

# work in all domains context by default (for plugins)
include FastGettext::TranslationMultidomain

# Keep TRANSLATORS comments
Rails.application.config.gettext_i18n_rails.xgettext = %w[--add-comments=TRANSLATORS:]
# Disable fuzzy .po merging
Rails.application.config.gettext_i18n_rails.msgmerge = %w[--no-fuzzy-matching]

# When mark_translated setting is set, we will wrap all translated strings
# which is useful when translating code base.
if SETTINGS[:mark_translated] && !Rails.env.test?
  include Foreman::Gettext::Debug
else
  include Foreman::Gettext::AllDomains
end
