require 'fast_gettext'

# include this module to see translations in the UI
module Foreman::Gettext::Debug
  DL = "\u00BB".encode("UTF-8") rescue '>'
  DR = "\u00AB".encode("UTF-8") rescue '<'

  # slightly modified copy of fast_gettext D_* method
  def _(key)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.d_(domain, key) { nil }
      return DL + result.to_s + DR unless result.nil?
    end
    DL + key.to_s + DR
  end

  # slightly modified copy of fast_gettext D_* method
  def n_(*keys)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.dn_(domain, *keys) { nil }
      return DL + result.to_s + DR unless result.nil?
    end
    DL + keys[-3].split(keys[-2] || FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
  end

  # slightly modified copy of fast_gettext D_* method
  def s_(key, separator = nil)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.ds_(domain, key, separator) { nil }
      return DL + result.to_s + DR unless result.nil?
    end
    DL + key.split(separator || FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
  end

  # slightly modified copy of fast_gettext D_* method
  def ns_(*keys)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.dns_(domain, *keys) { nil }
      return DL + result.to_s + DR unless result.nil?
    end
    DL + keys[-2].split(FastGettext::NAMESPACE_SEPARATOR).last.to_s + DR
  end
end
