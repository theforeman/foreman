require 'fast_gettext'

# include this module to translate in all domains by default
module Foreman
  module Gettext
    module AllDomains
      def _(key)
        FastGettext::TranslationMultidomain.D_(key)
      end

      def n_(*keys)
        FastGettext::TranslationMultidomain.Dn_(*keys)
      end

      def s_(key, separator = nil)
        FastGettext::TranslationMultidomain.Ds_(key, separator)
      end

      def ns_(*keys)
        FastGettext::TranslationMultidomain.Dns_(*keys)
      end
    end
  end
end
