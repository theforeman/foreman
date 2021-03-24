module Foreman
  class Plugin
    module GraphqlPluginFields
      extend ActiveSupport::Concern

      module ClassMethods
        def realize_plugin_query_extensions(source = Foreman::Plugin.graphql_types_registry.plugin_query_fields)
          source.map do |plugin_type|
            if plugin_type[:options].empty?
              send plugin_type[:field_type], plugin_type[:field_name], Foreman::Module.resolve(plugin_type[:type])
            else
              send plugin_type[:field_type], plugin_type[:field_name], apply_type(plugin_type[:type]), plugin_type[:options]
            end
          end
        end

        def realize_plugin_mutation_extensions(source = Foreman::Plugin.graphql_types_registry.plugin_mutation_fields)
          source.map do |plugin_type|
            send :field, plugin_type[:field_name], mutation: Foreman::Module.resolve(plugin_type[:mutation])
          end
        end

        def apply_type(field_type)
          field_type.respond_to?(:call) ? field_type.call : Foreman::Module.resolve(field_type)
        end
      end
    end
  end
end
