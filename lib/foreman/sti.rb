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
        base.alias_method_chain :save, :type
      end
    end
    def save_with_type(*args)
      type_changed = self.type_changed?
      self.class.instance_variable_set("@finder_needs_type_condition", :false) if type_changed
      value = save_without_type(*args)
    ensure
      self.class.instance_variable_set("@finder_needs_type_condition", :true) if type_changed
    end
  end
end
