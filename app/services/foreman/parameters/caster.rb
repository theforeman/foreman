module Foreman
  module Parameters
    class Caster
      attr_reader :value

      def initialize(item, options = {})
        defaults = {
          :attribute_name => :value,
          :to => :string,
        }
        options.reverse_merge!(defaults)
        @item, @options = item, options
        @value = @options[:value].nil? ? @item.send(@options[:attribute_name]) : @options[:value]
      end

      def cast!
        @item.send("#{@options[:attribute_name]}=", casted_value)
      end

      def cast
        casted_value
      end

      private

      def casted_value
        case @options[:to].to_s
        when "string"
          cast_string
        when "integer"
          cast_integer
        when "real"
          cast_real
        when "boolean"
          cast_boolean
        when "array"
          cast_array
        when "hash"
          cast_hash
        when "json"
          cast_json
        when "yaml"
          cast_yaml
        when nil, ""
          value
        else
          Rails.logger.warn("Unable to type cast #{value} to #{@options[:to]}")
          raise TypeError
        end
      end

      def cast_string
        value.to_s
      end

      def cast_boolean
        return nil if value == ""
        val = ActiveRecord::Type::Boolean.new.deserialize(value)
        return val if [true, false].include?(val)
        raise TypeError
      end

      def cast_integer
        return value.to_i if value.is_a?(Numeric)

        if value.is_a?(String)
          if value =~ /^0x[0-9a-f]+$/i
            value.to_i(16)
          elsif value =~ /^0[0-7]+$/
            value.to_i(8)
          elsif value =~ /^-?\d+$/
            value.to_i
          else
            raise TypeError
          end
        end
      end

      def cast_real
        return value if value.is_a? Numeric
        if value.is_a?(String)
          if value =~ /\A[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?\Z/
            value.to_f
          else
            cast_integer
          end
        end
      end

      def cast_array
        return value if value.is_a? Array
        return value.to_a if !value.is_a?(String) && value.is_a?(Enumerable)
        val = load_yaml_or_json
        raise TypeError unless val.is_a? Array
        val
      end

      def cast_hash
        return value if value.is_a? Hash
        val = load_yaml_or_json
        raise TypeError unless val.is_a? Hash
        val
      end

      def cast_json
        JSON.load value
      end

      def cast_yaml
        YAML.load value
      end

      def load_yaml_or_json
        return value unless value.is_a? String
        begin
          YAML.load value
        rescue Psych::SyntaxError
          JSON.load value
        end
      end
    end
  end
end
