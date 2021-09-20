module FactImporters
  module Normalizers
    class Base
      delegate :logger, :to => :Rails

      def initialize(facts, excluded_facts)
        @facts = facts
        @excluded_facts = excluded_facts
      end

      def normalize
        normalized_facts = {}
        @facts.each do |k, v|
          key = k.to_s
          val = v.to_s

          normalized_facts[key] = val unless val.empty? || key.match(@excluded_facts)
        end
        normalized_facts
      end
    end
  end
end
