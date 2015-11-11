require 'test_helper'

class TestModel
end

module TestExtension
end

class FacetConfigurationTest < ActiveSupport::TestCase
  class TestClass < HostFacetBase
  end

  teardown do
    Host::Managed.cloned_parameters[:include].delete(:test_model)
    Host::Managed.cloned_parameters[:include].delete(:test_facet)
    Host::Managed.cloned_parameters[:include].delete(:facet_name)
  end

  test 'enables block configuration' do
    config = Facets::Configuration.new
    Facets.stubs(:configuration).returns(config)

    assert_difference('config.registered_facets.count', 1) do
      Facets.configure do
        register 'TestFacet', :test_model
      end
    end
  end

  test 'gives readonly access to the registry' do
    config = Facets::Configuration.new
    config.register 'TestFacet', :test_model
    assert_difference('config.registered_facets.count', 0) do
      config.registered_facets.delete(:test_facet)
    end
  end

  context 'single entry' do
    test 'defaults initialization' do
      config = Facets::Configuration.new
      config.register 'TestModel'
      facet_configuration = config.registered_facets[:test_model]
      assert_equal :test_model, facet_configuration.name
      assert_equal :test_model, facet_configuration.model
    end

    test 'extended initialization' do
      config = Facets::Configuration.new
      config.register 'TestFacet', :test_model do
        add_helper :test_helper
        extend_model :test_extension
      end
      facet_configuration = config.registered_facets[:test_facet]
      assert_equal :test_facet, facet_configuration.name
      assert_equal :test_model, facet_configuration.model
      assert_equal :test_helper, facet_configuration.helper
      assert_equal :test_extension, facet_configuration.extension
    end

    test 'exposes xxx_class properties' do
      config = Facets::Configuration.new
      config.register 'TestFacet', 'FacetConfigurationTest::TestClass'
      facet_configuration = config.registered_facets[:test_facet]
      assert_equal FacetConfigurationTest::TestClass, facet_configuration.model_class
    end

    test 'accepts class as model' do
      config = Facets::Configuration.new
      config.register :facet_name, FacetConfigurationTest::TestClass

      facet_configuration = config.registered_facets[:facet_name]
      assert_equal FacetConfigurationTest::TestClass, facet_configuration.model_class
    end

    test 'accepts module as extension' do
      config = Facets::Configuration.new
      config.register :test_model do
        extend_model TestExtension
      end

      facet_configuration = config.registered_facets[:test_model]
      assert_equal :test_extension, facet_configuration.extension
    end
  end
end
