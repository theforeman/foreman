module Foreman
  module STI
    def self.prepended(base)
      class << base
        cattr_accessor :preloaded, instance_accessor: false
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

    def save(*args)
      type_changed = type_changed?
      self.class.instance_variable_set("@finder_needs_type_condition", :false) if type_changed
      super
    ensure
      self.class.instance_variable_set("@finder_needs_type_condition", :true) if type_changed
    end

    def descendants
      preload_sti unless preloaded
      super
    end

    # Taken from
    # https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance

    # Constantizes all types present in the database. There might be more on
    # disk, but that does not matter in practice as far as the STI API is
    # concerned.
    #
    # Assumes store_full_sti_class is true, the default.
    def preload_sti
      puts "#{self}: #{base_class.connected?} #{base_class.table_exists?}"
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
end
