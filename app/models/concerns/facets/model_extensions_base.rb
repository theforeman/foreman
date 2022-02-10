require_dependency 'facets'

module Facets
  module ModelExtensionsBase
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module ClassMethods
      def configure_facet(facet_type, base_model_symbol, base_model_id_field, &block)
        config = OpenStruct.new(
          facet_type: facet_type,
          base_model_symbol: base_model_symbol,
          base_model_id_field: base_model_id_field)
        config.callback = block

        facet_configurations << config

        Facets.registered_facets.values.each do |entry|
          register_facet_relation_for_type(entry, config) if entry.has_configuration(config.facet_type)
        end

        Facets.after_entry_created do |entry|
          register_facet_relation_for_type(entry, config) if entry.has_configuration(config.facet_type)
        end
      end

      def facet_configurations
        @facet_configurations ||= []
      end

      # This method is used to add all relation objects necessary for accessing facet from the host object.
      # It:
      # 1. Adds active record one to one association
      # 2. Adds the ability to set facet's attributes via Model#attributes= method
      # 3. Extends model with extension module defined by facet's configuration
      # 4. Includes facet in host's cloning mechanism
      # 5. Adds compatibility properties forwarders so old property calls will still work after moving them to a facet:
      #    host.foo # => will call Host.my_facet.foo
      def register_facet_relation(facet_config)
        facet_configurations.each do |extension_config|
          register_facet_relation_for_type(facet_config, extension_config)
        end
      end

      def register_facet_relation_for_type(facet_config, extension_config)
        return unless facet_config.has_configuration(extension_config.facet_type)
        type_config = facet_config.send "#{extension_config.facet_type}_configuration"
        facet_name = facet_config.name

        extend_model_attributes(type_config, facet_name, extension_config)
        extend_model(type_config, facet_name)
        handle_migrations(type_config, facet_name)

        extension_config.callback&.call(facet_config)
      end

      def handle_migrations(type_config, facet_name)
        return unless Foreman.in_setup_db_rake?
        # To prevent running into issues in old migrations when new facet is defined but not migrated yet.
        # We define it only when in migration to avoid this unnecessary checks outside for the migration
        @facet_relation_db_migrate_extensions ||= {} # prevent duplicates
        return if @facet_relation_db_migrate_extensions.key?(facet_name)
        @facet_relation_db_migrate_extensions[facet_name] = Module.new do
          define_method(facet_name) do
            if type_config.model.table_exists?
              super()
            else
              logger.warn("Table for #{facet_name} not defined yet: skipping the facet data")
              nil
            end
          end
        end
        prepend @facet_relation_db_migrate_extensions[facet_name]
      end

      def extend_model(type_config, facet_name)
        include type_config.extension if type_config.extension

        type_config.compatibility_properties&.each do |prop|
          define_method(prop) { |*args| forward_property_call(prop, args, facet_name) }
        end
      end

      def extend_model_attributes(type_config, facet_name, extension_config)
        has_one facet_name,
          :class_name => type_config.model.name,
          :foreign_key => extension_config.base_model_id_field,
          :inverse_of => extension_config.base_model_symbol,
          :dependent => type_config.dependent
        accepts_nested_attributes_for facet_name, :update_only => true, :reject_if => :all_blank

        alias_method "#{facet_name}_attributes", facet_name
      end
    end

    # define instance methods in a module, so they will be set
    # even for models that do not include this module directly
    # like in case Hostgroup -> HostgroupExtensions -> ModelExtensionsBase
    module InstanceMethods
      def attributes
        hash = super

        # include all facet attributes by default
        facet_definitions.each do |definition|
          facet = definition.facet_record_for(self)
          next unless facet
          hash["#{definition.name}_attributes"] = facet.attributes.reject { |key| %w(created_at updated_at).include? key }
        end
        hash
      end

      def facets
        facet_definitions.map { |definition| definition.facet_record_for(self) }.compact
      end

      # This method will return array of all definitions registered for this model.
      # output will look like:
      #   => [Facets.registered_facets[:puppet].configuration_for(:host), Facets.registered_facets[:content].configuration_for(:host)]
      def facet_definitions
        entries = []
        self.class.facet_configurations.each do |config|
          entries.concat(Facets.facets_for_type(config.facet_type))
        end
        entries
      end

      private

      # Overrides ActiveRecord::NestedAttributes#call_reject_if
      # we want to reject empty attributes only for new facets
      # the existing record is already fetched so checking the record itself doesn't create overhead
      # it is fetched in nested_attributes in:
      # https://github.com/rails/rails/blob/6bfc637659248df5d6719a86d2981b52662d9b50/activerecord/lib/active_record/nested_attributes.rb#L411
      def call_reject_if(association_name, attributes)
        is_facet_assoc = facet_definitions.detect { |definition| definition.name.to_s == association_name.to_s }
        if is_facet_assoc
          # reject only if record doesn't exist yet
          send(association_name).nil? && super
        else
          super
        end
      end
    end

    private

    def forward_property_call(property, args, facet)
      facet_instance = send(facet)
      return nil unless facet_instance

      facet_instance.send(property, *args)
    end
  end
end
