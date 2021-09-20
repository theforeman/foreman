module FactImporters
  module Normalizers
    class Katello < Structured
      def initialize(facts, excluded_facts)
        @facts = facts
        @excluded_facts = excluded_facts
      end

      def normalize
        @facts = change_separator(@facts)
        super
      end

      def change_separator(facts)
        facts.map do |key, value|
          [key.gsub('.', FactName::SEPARATOR), value]
        end.to_h
      end
    end
  end
end
