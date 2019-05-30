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
end
