module Safemode
  class Blankslate
    @@allow_instance_methods = ['class', 'inspect', 'methods', 'respond_to?', 'to_s', 'instance_variable_get']
    @@allow_class_methods    = ['methods', 'new', 'name', 'inspect', '<', 'ancestors', '=='] # < needed in Rails Object#subclasses_of

    silently { undef_methods(*instance_methods - @@allow_instance_methods) }
    class << self
      silently { undef_methods(*instance_methods - @@allow_class_methods) }

      def method_added(name) end # ActiveSupport needs this

      def inherited(subclass)
        subclass.init_allowed_methods(@allowed_methods)
      end

      def init_allowed_methods(allowed_methods)
        @allowed_methods = allowed_methods
      end

      def allowed_methods
        @allowed_methods ||= []
      end

      def allow(*names)
        @allowed_methods = allowed_methods + names.map{|name| name.to_s}
        @allowed_methods.uniq!
      end

      def allowed?(name)
        allowed_methods.include? name.to_s
      end
    end
  end
end
