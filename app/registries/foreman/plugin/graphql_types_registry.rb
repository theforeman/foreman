module Foreman
  class Plugin
    class GraphqlTypesRegistry
      delegate :logger, to: Rails
      attr_reader :type_block_extensions, :type_module_extensions, :plugin_query_fields, :plugin_mutation_fields

      def initialize
        @type_block_extensions = {}
        @type_module_extensions = {}
        @plugin_query_fields = []
        @plugin_mutation_fields = []
      end

      def register_plugin_query_field(field_name, type, field_type, options = {})
        unless [:record_field, :collection_field, :field].any? { |field| field == field_type }
          raise "expected :record_field, :collection_field or :field as a field_type, got #{field_type}"
        end
        if [:record_field, :collection_field].any? { |field| field == field_type && !options.empty? }
          raise "options are allowed only for :field"
        end
        @plugin_query_fields << { :field_type => field_type, :field_name => field_name, :type => type, :options => options }
      end

      def register_plugin_mutation_field(field_name, mutation)
        @plugin_mutation_fields << { :field_name => field_name, :mutation => mutation }
      end

      # Register a new extension for a graphql type
      def register_extension(type:, with_module: nil, &block)
        return register_block_extension(type: type, &block) if block_given?
        register_module_extension(type: type, with_module: with_module)
      end

      def register_block_extension(type:, &block)
        @type_block_extensions[type] ||= []
        @type_block_extensions[type] << block
      end

      def register_module_extension(type:, with_module:)
        @type_module_extensions[type] ||= []
        @type_module_extensions[type] << with_module
      end

      # Realises previously registered extensions
      def realise_extensions
        realise_block_extensions && realise_module_extensions
      end

      def realise_block_extensions
        type_block_extensions.each do |type, extensions|
          type = Foreman::Module.resolve(type)
          extensions.each do |extension|
            type.class_eval(&extension)
          end
        end
      end

      def realise_module_extensions
        type_module_extensions.each do |type, extensions|
          type = Foreman::Module.resolve(type)
          extensions.each do |extension|
            extension = Foreman::Module.resolve(extension)
            type.send(:include, extension)
          end
        end
      end
    end
  end
end
