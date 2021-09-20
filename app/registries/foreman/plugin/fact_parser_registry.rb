module Foreman
  class Plugin
    class FactParserRegistry
      def initialize
        @parsers = {}.with_indifferent_access
      end

      # @return Parser class for the given key
      # If the default parser is registered and unknown +key+ is used,
      # the default parser is returned
      #
      # === Examples
      #   FactParserRegistry[:puppet] # => PuppetParser
      #   FactParserRegistry[:no_name] # => NoNameParser
      #   FactParserRegistry[:unknown_key] # => PuppetParser (Puppet parser is registered as default)
      def [](key)
        @parsers[key]
      end

      # Register a fact parser (at +parser+ variable) to the Parser Registry for a given +key+.
      # It's possible to mark +parser+ as default. It's then used for unknown +key+s.
      # +key+ - key symbol to find parser, eg. :puppet
      # +parser+ - class of parser, eg. PuppetParser
      # +default+ - mark if the parser will be the default option for unknown keys, false by default.
      #             There can only be one default.
      #
      # === Examples
      #   FactParserRegistry.registry(:puppet, PuppetParser, true)
      #   FactParserRegistry.registry(:no_name, NoNameParser)
      def register(key, parser, default = false)
        if (old_parser = @parsers[key]) && old_parser != @parsers.default
          Rails.logger.warn("WARNING: Parser #{old_parser} for type #{key} is replaced with #{parser}")
        end

        @parsers.default = parser if default
        @parsers[key.to_sym] = parser
      end

      # Remove a parser from the registry
      def unregister(key)
        @parsers.delete(key)
      end

      # @return Array of features for smart proxy of the registered parsers
      def fact_features
        @parsers.values.map { |parser| parser.smart_proxy_features }.compact.flatten.uniq
      end
    end
  end
end
