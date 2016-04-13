module Foreman
  module STI
    extend ActiveSupport::Concern

    included do
      singleton_class.class_eval do
        alias_method_chain :new, :cast
      end
      alias_method_chain :save, :type
    end

    module ClassMethods
      # ensures that the correct STI object is created when :type is passed.
      def new_with_cast(*attributes, &block)
        default_type = self.respond_to?(:default_sti_class) && self.default_sti_class
        if ((h = attributes.first).is_a?(Hash) && (type_attr = h.with_indifferent_access.delete(:type)) && type_attr.length > 0) || default_type
          if (type = type_attr || default_type) && (klass = type.constantize) != self
            raise "Invalid type #{type}" unless klass <= self
            return klass.new(*attributes, &block)
          end
        end

        new_without_cast(*attributes, &block)
      end
    end

    def save_with_type(*args)
      type_changed = self.type_changed?
      self.class.instance_variable_set("@finder_needs_type_condition", :false) if type_changed
      save_without_type(*args)
    ensure
      self.class.instance_variable_set("@finder_needs_type_condition", :true) if type_changed
    end
  end
end
