module Types
  class LocaleEnum < Types::BaseEnum
    FastGettext.default_available_locales.each do |locale|
      value locale, description: locale
    end
  end
end
