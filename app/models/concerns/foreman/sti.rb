module Foreman
  module STI
    extend ActiveSupport::Concern

    class_methods do
      # ensures that the correct STI object is created when :type is passed.
      def new(attributes = nil, &block)
        if attributes.is_a?(Hash) && (type = attributes.with_indifferent_access.delete(:type)).present? && (klass = type.constantize) != self
          raise "Invalid type #{type}" unless klass <= self
          return klass.new(attributes, &block)
        end

        super
      end
    end
  end
end
