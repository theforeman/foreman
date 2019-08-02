require 'test_helper'

class Foreman::Plugin::GraphqlTypesRegistryTest < ActiveSupport::TestCase
  module ExtensionModule
    def foo
      'bar'
    end
  end

  let(:registry) { Foreman::Plugin::GraphqlTypesRegistry.new }
  let(:type_for_testing) { Class.new }

  describe 'a block extension' do
    setup do
      assert_equal 0, registry.type_block_extensions.size

      registry.register_extension type: type_for_testing do
        def foo
          'bar'
        end
      end
    end

    it 'registers a block extension' do
      assert_equal 1, registry.type_block_extensions.size
      assert registry.type_block_extensions.values.flatten.all? { |blk| blk.is_a?(Proc) }
    end

    it 'realizes a block extension' do
      assert_not_includes type_for_testing.instance_methods, :foo
      registry.realise_extensions
      assert_includes type_for_testing.instance_methods, :foo
    end
  end

  describe 'a module extension' do
    setup do
      assert_equal 0, registry.type_block_extensions.size

      registry.register_extension type: type_for_testing, with_module: ExtensionModule
    end

    it 'registers a module extension' do
      assert_equal 1, registry.type_module_extensions.size
      assert registry.type_module_extensions.values.flatten.all? { |mod| mod.is_a?(Module) }
    end

    it 'realizes a module extension' do
      assert_not_includes type_for_testing.instance_methods, :foo
      registry.realise_extensions
      assert_includes type_for_testing.instance_methods, :foo
    end
  end

  describe 'plugin fields' do
    setup do
      assert_equal 0, registry.plugin_query_fields.size
      assert_equal 0, registry.plugin_mutation_fields.size
    end

    it 'registers plugin query fields' do
      registry.register_plugin_query_field :baz, 'TestType', :record_field
      assert_equal 1, registry.plugin_query_fields.size
      assert_equal :baz, registry.plugin_query_fields.first[:field_name]
      assert_equal :record_field, registry.plugin_query_fields.first[:field_type]
      assert_equal 'TestType', registry.plugin_query_fields.first[:type]
    end

    it 'raises on invalid field type' do
      err = assert_raises RuntimeError do
        registry.register_plugin_query_field :woof, 'TestType', :custom_field
      end
      assert_equal err.message, "expected :record_field or :collection_field as a field_type, got custom_field"
    end

    it 'registeres plugin mutation fields' do
      registry.register_plugin_mutation_field :boom, 'TestType'
      assert_equal 1, registry.plugin_mutation_fields.size
      assert_equal :boom, registry.plugin_mutation_fields.first[:field_name]
      assert_equal 'TestType', registry.plugin_mutation_fields.first[:mutation]
    end
  end
end
