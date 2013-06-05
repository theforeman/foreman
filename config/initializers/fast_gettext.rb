require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(Rails.root, 'locale')
locale_domain = 'foreman'

if Rails.env.development?
  # no need to generate MO files for development mode
  locale_type = :po
  locale_search_path = File.join(locale_dir, "*", "#{locale_domain}.#{locale_type}")
  locale_search_re   = Regexp.new(".*/([^/]*)/#{locale_domain}.#{locale_type}")
else
  locale_type = :mo
  locale_search_path = File.join(locale_dir, "*", "LC_MESSAGES", "#{locale_domain}.#{locale_type}")
  locale_search_re   = Regexp.new(".*/([^/]*)/LC_MESSAGES/#{locale_domain}.#{locale_type}")
end

begin
  if Rails.env.test?
    # in test mode we do not support i18n
    FastGettext.default_available_locales = ['en']
  else
    FastGettext.default_available_locales = Dir.glob(locale_search_path).collect {|f| locale_search_re.match(f)[1] }
  end
rescue Exception => e
  Rails.logger.warn "Unable to set available locales: #{e}"
  FastGettext.default_available_locales = ['en']
end

# initialize fast gettext
FastGettext.add_text_domain locale_domain,
  :path => locale_dir,
  :type => locale_type,
  :ignore_fuzzy => true,
  :report_warning => false
FastGettext.default_text_domain = locale_domain

# create list of human-readable locale names
FastGettext.class.class_eval { attr_accessor :human_available_locales }
FastGettext.human_available_locales = []
FastGettext.default_available_locales.sort.each do |locale|
  FastGettext.locale = locale
  # TRANSLATORS: Provide locale name in native language (e.g. English, Deutsch or Português)
  human_locale = _("locale_name")
  human_locale = locale if human_locale == "locale_name"
  FastGettext.human_available_locales << [ human_locale, locale ]
end
FastGettext.locale = "en"

# When mark_translated setting is set, we will wrap all translated strings
# which is useful when translating code base.
if SETTINGS[:mark_translated] and not Rails.env.test?
  module FastGettext
    module Translation
      alias :old_ :_
      alias :olds_ :s_
      alias :oldn_ :n_

      def _(*args)
        "X" + old_(*args) + "X"
      end

      def s_(*args)
        "X" + olds_(*args) + "X"
      end

      def n_(*args)
        "X" + oldn_(*args) + "X"
      end
    end
  end
end
