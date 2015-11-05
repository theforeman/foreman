require 'test_helper'

class FacetConfigurationTest < ActiveSupport::TestCase
  class TestClass
  end

  test 'enables block configuration' do
    config = Facets::Configuration.new
    Facets.expects(:configuration).returns(config)

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
      config.registered_facets.delete(:TestFacet)
    end
  end

  context 'single entry' do
    test 'defaults initialization' do
      config = Facets::Configuration.new
      config.register 'TestFacet'
      facet_configuration = config.registered_facets[:TestFacet]
      assert_equal :TestFacet, facet_configuration.name
      assert_equal :test_facet, facet_configuration.model
    end

    test 'extended initialization' do
      config = Facets::Configuration.new
      config.register 'TestFacet', :test_model do
        add_helper :test_helper
        extend_model :test_extension
      end
      facet_configuration = config.registered_facets[:TestFacet]
      assert_equal :TestFacet, facet_configuration.name
      assert_equal :test_model, facet_configuration.model
      assert_equal :test_helper, facet_configuration.helper
      assert_equal :test_extension, facet_configuration.extension
    end

    test 'exposes xxx_class properties' do
      config = Facets::Configuration.new
      config.register 'TestFacet', 'FacetConfigurationTest::TestClass'
      facet_configuration = config.registered_facets[:TestFacet]
      assert_equal FacetConfigurationTest::TestClass, facet_configuration.model_class
    end
  end
end
