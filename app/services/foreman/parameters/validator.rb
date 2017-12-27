module Foreman
  module Parameters
    class Validator
      def initialize(item, options = {})
        @item, @options = item, options
      end

      def validate!
        case @options[:type].to_s
        when "regexp"
          validate_regexp
        when "list", "array"
          validate_list
        else
          true
        end
      end

      private

      def value
        @item.send(@options[:getter])
      end

      def validate_regexp
        return true if value.contains_erb? && Setting[:interpolate_erb_in_parameters]

        unless value =~ /#{@options[:validate_with]}/
          add_error(_("is invalid"))
          return false
        end
        true
      end

      def validate_list
        return true if value.contains_erb? && Setting[:interpolate_erb_in_parameters] ||
          @options[:validate_with].blank?
        unless @options[:validate_with].split(LookupKey::KEY_DELM).map(&:strip).include?(value.to_s)
          add_error(_("%{value} is not one of %{rules}") % { :value => value, :rules => @options[:validate_with] })
          return false
        end
        true
      end

      def add_error(message)
        @item.errors.add(@options[:getter], message)
      end
    end
  end
end
