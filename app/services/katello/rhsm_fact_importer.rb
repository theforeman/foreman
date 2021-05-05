module Katello
  class RhsmFactImporter < ::StructuredFactImporter
    def fact_name_class
      Katello::RhsmFactName
    end

    def normalize(facts)
      facts = change_separator(facts)
      super(facts)
    end

    def change_separator(facts)
      to_ret = {}
      facts.each do |key, value|
        to_ret[key.split('.').join(RhsmFactName::SEPARATOR)] = value
      end
      to_ret
    end
  end
end
