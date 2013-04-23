require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(File.dirname(__FILE__), '..', '..', 'locale')
if Rails.env.development?
  # no need to generate MO files for development mode
  locale_type = :po
else
  locale_type = :mo
end

if Rails.env.test?
  # in test mode we do not support i18n
  default_available_locales = []
else
  default_available_locales = Dir.entries(locale_dir).reject {|d| d =~ /(^\.|pot$)/ }
end

FastGettext.add_text_domain 'foreman',
  :path => locale_dir,
  :type => locale_type,
  :ignore_fuzzy => true,
  :report_warning => false
FastGettext.default_available_locales = ['en'] + default_available_locales
FastGettext.default_text_domain = 'foreman'

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
