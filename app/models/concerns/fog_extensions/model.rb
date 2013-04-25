module FogExtensions
  module Model
    def self.included(base)
      base.send :include, InstanceMethods
      base.class_eval do
        attr_accessor :_delete
      end
    end

    module InstanceMethods

      def persisted?
        !!identity
      end

      def to_json(options={ })
        ActiveSupport::JSON.encode(self, options)
      end

      def as_json(options = { })
        attr = attributes.dup
        attr.delete(:client)
        attr
      end
    end
  end
end