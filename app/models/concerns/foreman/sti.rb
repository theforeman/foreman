module Foreman
  module STI
    extend ActiveSupport::Concern

    prepended do
      cattr_accessor :preloaded, instance_accessor: false
    end

    class_methods do
      # ensures that the correct STI object is created when :type is passed.
      def new(attributes = nil, &block)
        if attributes.is_a?(Hash) && (type = attributes.with_indifferent_access.delete(:type)) && !type.empty?
          if (klass = type.constantize) != self
            raise "Invalid type #{type}" unless klass <= self
            return klass.new(attributes, &block)
          end
        end

        super
      end

      def descendants
        preload_sti unless preloaded
        super
      end

      # Constantizes all types present in the database. There might be more on
      # disk, but that does not matter in practice as far as the STI API is
      # concerned.
      #
      # Assumes store_full_sti_class is true, the default.
      def preload_sti
        return [] unless base_class.connected? && base_class.table_exists?
        types_in_db = base_class
                          .unscoped
                          .select(inheritance_column)
                          .distinct
                          .pluck(inheritance_column)
                          .compact

        types_in_db.each do |type|
          logger.debug("Preloading STI type #{type}")
          type.constantize
        end

        self.preloaded = true
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
