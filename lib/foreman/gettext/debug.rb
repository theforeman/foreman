require 'fast_gettext'

# include this module to see translations in the UI
module Foreman::Gettext::Debug

  # slightly modified copy of fast_gettext D_* method
  def _(key)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.d_(domain, key) {nil}
      return "X#{result}X" unless result.nil?
    end
    'X' + key + 'X'
  end

  # slightly modified copy of fast_gettext D_* method
  def n_(*keys)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.dn_(domain, *keys) {nil}
      return "X#{result}X" unless result.nil?
    end
    'X' + keys[-3].split(keys[-2]||FastGettext::NAMESPACE_SEPARATOR).last + 'X'
  end

  # slightly modified copy of fast_gettext D_* method
  def s_(key, separator=nil)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.ds_(domain, key, separator) {nil}
      return "X#{result}X" unless result.nil?
    end
    'X' + key.split(separator||FastGettext::NAMESPACE_SEPARATOR).last + 'X'
  end

  # slightly modified copy of fast_gettext D_* method
  def ns_(*keys)
    FastGettext.translation_repositories.each_key do |domain|
      result = FastGettext::TranslationMultidomain.dns_(domain, *keys) {nil}
      return "X#{result}X" unless result.nil?
    end
    'X' + keys[-2].split(FastGettext::NAMESPACE_SEPARATOR).last + 'X'
  end
end
