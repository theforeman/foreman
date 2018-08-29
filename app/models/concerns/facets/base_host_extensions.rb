require 'facets'

module Facets
  module BaseHostExtensions
    extend ActiveSupport::Concern

    included do
      Facets::BaseHostExtensions.refresh_facet_relations(self)

      def attributes
        hash = super

        # include all facet attributes by default
        facets_with_definitions.each do |facet, facet_definition|
          hash["#{facet_definition.name}_attributes"] = facet.attributes.reject { |key| %w(created_at updated_at).include? key }
        end
        hash
      end
    end

    class << self
      def refresh_facet_relations(klass)
        Facets.registered_facets.values.each do |facet_config|
          self.register_facet_relation(klass, facet_config)
        end
      end

      # This method is used to add all relation objects necessary for accessing facet from the host object.
      # It:
      # 1. Adds active record one to one association
      # 2. Adds the ability to set facet's attributes via Host#attributes= method
      # 3. Extends Host::Managed model with extension module defined by facet's configuration
      # 4. Includes facet in host's cloning mechanism
      # 5. Adds compatibility properties forwarders so old property calls will still work after moving them to a facet:
      #    host.foo # => will call Host.my_facet.foo
      def register_facet_relation(klass, facet_config)
        klass.class_eval do
          has_one facet_config.name, :class_name => facet_config.model.name, :foreign_key => :host_id, :inverse_of => :host, :dependent => facet_config.dependent
          accepts_nested_attributes_for facet_config.name, :update_only => true, :reject_if => :all_blank
          if Foreman.in_setup_db_rake?
            # To prevent running into issues in old migrations when new facet is defined but not migrated yet.
            # We define it only when in migration to avoid this unnecessary checks outside for the migration
            @facet_relation_db_migrate_extensions ||= {} # prevent duplicates
            unless @facet_relation_db_migrate_extensions.key?(facet_config.name)
              @facet_relation_db_migrate_extensions[facet_config.name] = Module.new do
                define_method(facet_config.name) do
                  if facet_config.model.table_exists?
                    super()
                  else
                    logger.warn("Table for #{facet_config.name} not defined yet: skipping the facet data")
                    nil
                  end
                end
              end
              prepend @facet_relation_db_migrate_extensions[facet_config.name]
            end
          end
          alias_method "#{facet_config.name}_attributes", facet_config.name

          include facet_config.extension if facet_config.extension

          facet_config.compatibility_properties&.each do |prop|
            define_method(prop) { |*args| forward_property_call(prop, args, facet_config.name) }
          end
        end
      end
    end

    def facets
      facets_with_definitions.keys
    end

    # This method will return a hash of facets for a specific host including the coresponding definitions.
    # The output should look like this:
    # { host.puppet_aspect => Facets.registered_facets[:puppet_aspect] }
    def facets_with_definitions
      Hash[(Facets.registered_facets.values.map do |facet_config|
        facet = send(facet_config.name)
        [facet, facet_config] if facet
      end).compact]
    end

    # This method will return attributes list augmented with attributes that are
    # set by the facet. Each registered facet will get opportunity to add its
    # own attributes to the list.
    def apply_facet_attributes(hostgroup, attributes)
      Facets.registered_facets.values.map do |facet_config|
        facet_attributes = attributes["#{facet_config.name}_attributes"] || {}
        facet_attributes = facet_config.model.inherited_attributes(hostgroup, facet_attributes)
        attributes["#{facet_config.name}_attributes"] = facet_attributes unless facet_attributes.empty?
      end
      attributes
    end

    def populate_facet_fields(parser, type, source_proxy)
      Facets.registered_facets.values.each do |facet_config|
        facet_config.model.populate_fields_from_facts(self, parser, type, source_proxy)
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
