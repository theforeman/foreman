module Foreman
  class Plugin
    module GraphqlPluginFields
      extend ActiveSupport::Concern

      module ClassMethods
        def realize_plugin_query_extensions(source = Foreman::Plugin.graphql_types_registry.plugin_query_fields)
          source.map do |plugin_type|
            send plugin_type[:field_type], plugin_type[:field_name], Foreman::Module.resolve(plugin_type[:type])
          end
        end

        def realize_plugin_mutation_extensions(source = Foreman::Plugin.graphql_types_registry.plugin_mutation_fields)
          source.map do |plugin_type|
            send :field, plugin_type[:field_name], mutation: Foreman::Module.resolve(plugin_type[:mutation])
          end
        end
      end
    end
  end
end
