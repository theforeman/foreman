# include this module to translate in all domains by default
module Foreman
  module Gettext
    module AllDomains
      class Localizer
        prepend FastGettext::TranslationMultidomain
      end

      def self.localizer
        @localizer ||= Localizer.new
      end

      def _(key)
        Foreman::Gettext::AllDomains.localizer.D_(key)
      end

      def n_(*keys)
        Foreman::Gettext::AllDomains.localizer.Dn_(*keys)
      end

      def s_(key, separator = nil)
        Foreman::Gettext::AllDomains.localizer.Ds_(key, separator)
      end

      def ns_(*keys)
        Foreman::Gettext::AllDomains.localizer.Dns_(*keys)
      end
    end
  end
end
