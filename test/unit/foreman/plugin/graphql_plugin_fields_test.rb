require "test_helper"

class Foreman::Plugin::GraphqlPluginFieldsTest < ActiveSupport::TestCase
  class GraphqlType
    include ::Foreman::Plugin::GraphqlPluginFields

    class << self
      attr_accessor :record_fields, :collection_fields, :mutation_fields

      def record_field(name, type)
        push_item :record_fields, name, type
      end

      def collection_field(name, type)
        push_item :collection_fields, name, type
      end

      def field(name, mutation)
        item = { :name => name, :mutation => mutation }
        @mutation_fields ? @mutation_fields << item : @mutation_fields = [item]
      end

      private

      def push_item(place, name, type)
        item = { :name => name, :type => type }
        instance_var = instance_variable_get("@#{place}")
        instance_var ? instance_var << item : instance_variable_set("@#{place}", [item])
      end
    end
  end

  describe 'graphql plugin query fields' do
    it 'adds a record field' do
      registry = Foreman::Plugin::GraphqlTypesRegistry.new.tap do |reg|
        reg.register_plugin_query_field :moo, 'Class', :record_field
      end

      klass = Class.new(GraphqlType)

      assert_nil klass.record_fields
      assert_nil klass.collection_fields
      klass.realize_plugin_query_extensions registry.plugin_query_fields

      assert_nil klass.collection_fields
      assert_equal 1, klass.record_fields.size
      assert_equal :moo, klass.record_fields.first[:name]
    end

    it 'adds a collection field' do
      registry = Foreman::Plugin::GraphqlTypesRegistry.new.tap do |reg|
        reg.register_plugin_query_field :woof, 'Class', :collection_field
      end

      klass = Class.new(GraphqlType)

      assert_nil klass.record_fields
      assert_nil klass.collection_fields
      klass.realize_plugin_query_extensions registry.plugin_query_fields

      assert_nil klass.record_fields
      assert_equal 1, klass.collection_fields.size
      assert_equal :woof, klass.collection_fields.first[:name]
    end
  end

  describe 'graphql plugin mutation fields' do
    it 'adds a mutation field' do
      registry = Foreman::Plugin::GraphqlTypesRegistry.new.tap do |reg|
        reg.register_plugin_mutation_field :quack, 'Class'
      end

      klass = Class.new(GraphqlType)

      assert_nil klass.mutation_fields
      klass.realize_plugin_mutation_extensions registry.plugin_mutation_fields
      assert_equal 1, klass.mutation_fields.size
      assert_equal :quack, klass.mutation_fields.first[:name]
    end
  end
end
