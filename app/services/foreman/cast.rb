module Foreman
  module Cast
    def self.to_bool(value)
      Foreman::Deprecation.deprecation_warning("3.6", "The method to_bool will be repaced by rails implementation.")

      case value

      when String
        return true if value =~ /\A(true|t|yes|y|on|1)\z/i
        return false if value.blank? || value =~ /\A(false|f|no|n|off|0)\z/i
        nil

      when Integer
        return true if value == 1
        return false if value == 0

      when NilClass
        false

      when TrueClass, FalseClass
        value

      end
    end
  end
end
