module Foreman
  module STI
    def self.included(base)
      base.class_eval do
        class << self
          # ensures that the correct STI object is created when :type is passed.
          def new_with_cast(*attributes, &block)
            if (h = attributes.first).is_a?(Hash) && (type = h.delete(:type)) && type.length > 0
              if (klass = type.constantize) != self
                raise "Invalid type #{type}" unless klass <= self
                return klass.new(*attributes, &block)
              end
            end

            new_without_cast(*attributes, &block)
          end

          alias_method_chain :new, :cast
        end
      end
    end
  end
end