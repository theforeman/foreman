module Types
  class LocaleEnum < Types::BaseEnum
    FastGettext.human_available_locales.each do |description, locale|
      value locale, description: description
    end
  end
end
