require 'fast_gettext'
require 'gettext_i18n_rails'

locale_dir = File.join(File.dirname(__FILE__), '..', '..', 'locale')
if Rails.env.development?
  # no need to generate MO files for development mode
  locale_type = :po
else
  locale_type = :mo
end

FastGettext.add_text_domain 'foreman', :path => locale_dir, :type => locale_type
FastGettext.default_available_locales = ['en'] + Dir.entries(locale_dir).reject {|d| d =~ /(^\.|pot$)/ }
FastGettext.default_text_domain = 'foreman'

# When mark_translated setting is set, we will wrap all translated strings
# which is useful when translating code base.
if SETTINGS[:mark_translated]
  module FastGettext
    module Translation
      alias :old_ :_

      def _(key)
        "X" + old_(key) + "X"
      end
    end
  end
end