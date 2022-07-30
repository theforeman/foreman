module Foreman
  module STI
    def self.prepended(base)
      class << base
        prepend ClassMethods
      end
    end

    module ClassMethods
      # ensures that the correct STI object is created when :type is passed.
      def new(*attributes, &block)
        if (h = attributes.first).is_a?(Hash) && (type = h.with_indifferent_access.delete(:type)) && !type.empty?
          if (klass = type.constantize) != self
            raise "Invalid type #{type}" unless klass <= self
            return klass.new(*attributes, &block)
          end
        end

        super
      end
    end

    def save(*args, **kwargs)
      type_changed = type_changed?
      self.class.instance_variable_set("@finder_needs_type_condition", :false) if type_changed
      super
    ensure
      self.class.instance_variable_set("@finder_needs_type_condition", :true) if type_changed
    end
  end
end
