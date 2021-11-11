# frozen_string_literal: true

module FactParsers
  module Utility
    # See sparse and unsparse documentation
    class FactSparser
      class << self
        # Sparses facts, so that it converts a facts hash
        # { operatingsystem : { major: 20, name : 'fedora' }
        # into
        # { operatingsystem::major: 20,
        #   operatingsystem::name: 'fedora' }
        def sparse(hash, options = {})
          hash.map do |k, v|
            prefix = options.fetch(:prefix, []) + [k]
            next sparse(v, options.merge(:prefix => prefix)) if v.is_a? Hash
            { prefix.join(options.fetch(:separator, FactName::SEPARATOR)) => v }
          end.reduce(:merge) || {}
        end

        # Unsparses facts, so that it converts a hash with facts
        # { operatingsystem::major: 20,
        #   operatingsystem::name: 'fedora' }
        # into
        # { operatingsystem : { major: 20, name: 'fedora' } }
        def unsparse(facts_hash)
          ret = {}
          sparse(facts_hash).each do |full_name, value|
            current = ret
            fact_name = full_name.to_s.split(FactName::SEPARATOR)
            current = (current[fact_name.shift] ||= {}) until fact_name.size <= 1
            current[fact_name.first] = value
          end
          ret
        end
      end
    end
  end
end
