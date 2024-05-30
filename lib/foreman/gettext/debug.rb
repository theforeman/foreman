require 'fast_gettext'

module Foreman
  module Gettext
    # include this module to see translations in the UI
    module Debug
      DL = "\u00BB".encode("UTF-8") rescue '>'
      DR = "\u00AB".encode("UTF-8") rescue '<'

      class Localizer
        prepend FastGettext::TranslationMultidomain
      end

      def self.localizer
        @localizer ||= Localizer.new
      end

      # slightly modified copy of fast_gettext D_* method
      def _(key)
        FastGettext.translation_repositories.each_key do |domain|
          result = Foreman::Gettext::Debug.localizer.d_(domain, key) { nil }
          return DL + result.to_s + DR unless result.nil?
        end
        DL + key.to_s + DR
      end

      # slightly modified copy of fast_gettext D_* method
      def n_(*keys)
        FastGettext.translation_repositories.each_key do |domain|
          result = Foreman::Gettext::Debug.localizer.dn_(domain, *keys) { nil }
          return DL + result.to_s + DR unless result.nil?
        end
        DL + keys[-3].split(keys[-2] || FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
      end

      # slightly modified copy of fast_gettext D_* method
      def s_(key, separator = nil)
        FastGettext.translation_repositories.each_key do |domain|
          result = Foreman::Gettext::Debug.localizer.ds_(domain, key, separator) { nil }
          return DL + result.to_s + DR unless result.nil?
        end
        DL + key.split(separator || FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
      end

      # slightly modified copy of fast_gettext D_* method
      def ns_(*keys)
        FastGettext.translation_repositories.each_key do |domain|
          result = Foreman::Gettext::Debug.localizer.dns_(domain, *keys) { nil }
          return DL + result.to_s + DR unless result.nil?
        end
        DL + keys[-2].split(FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
      end
    end
  end
end
