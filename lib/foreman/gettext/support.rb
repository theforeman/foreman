require 'fast_gettext'

module Foreman
  module Gettext
    module Support
      def self.detect_locale_type
        if Rails.env.development?
          :po
        else
          :mo
        end
      end

      def self.register_available_locales(locale_domain, locale_dir)
        locale_type = detect_locale_type

        if Rails.env.development?
          locale_search_path = File.join(locale_dir, "*", "#{locale_domain}.#{locale_type}")
          locale_search_re   = Regexp.new(".*/([^/]*)/#{locale_domain}.#{locale_type}")
        else
          locale_search_path = File.join(locale_dir, "*", "LC_MESSAGES", "#{locale_domain}.#{locale_type}")
          locale_search_re   = Regexp.new(".*/([^/]*)/LC_MESSAGES/#{locale_domain}.#{locale_type}")
        end

        begin
          if Rails.env.test?
            FastGettext.default_available_locales = ['en']
          else
            FastGettext.default_available_locales = Dir.glob(locale_search_path).collect { |f| locale_search_re.match(f)[1] }
          end
        rescue => e
          Rails.logger.warn "Unable to set available locales for domain #{locale_domain}: #{e}"
          FastGettext.default_available_locales = ['en']
        end
      end

      def self.add_text_domain(locale_domain, locale_dir)
        FastGettext.add_text_domain locale_domain,
          :path => locale_dir,
          :type => detect_locale_type,
          :ignore_fuzzy => true,
          :report_warning => false
      end

      def self.register_human_localenames
        original_locale = FastGettext.locale
        FastGettext.class.class_eval { attr_accessor :human_available_locales }
        FastGettext.human_available_locales = []
        FastGettext.default_available_locales.sort.each do |locale|
          FastGettext.locale = locale
          # TRANSLATORS: Provide locale name in native language (e.g. English, Deutsch or Portugues)
          human_locale = _("locale_name")
          human_locale = locale if human_locale == "locale_name"
          FastGettext.human_available_locales << [human_locale, locale]
        end
      ensure
        FastGettext.locale = original_locale
      end
    end
  end
end
