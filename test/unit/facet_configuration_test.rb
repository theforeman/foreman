require 'test_helper'

class TestModel
end

module TestExtension
end

class FacetConfigurationTest < ActiveSupport::TestCase
  class TestFacet < HostFacets::Base
  end
  module TestHelper
  end

  teardown do
    Host::Managed.cloned_parameters[:include].delete(:test_model)
    Host::Managed.cloned_parameters[:include].delete(:test_facet)
    Host::Managed.cloned_parameters[:include].delete(:facet_name)
  end

  test 'enables block configuration' do
    config = {}
    Facets.stubs(:configuration).returns(config)

    assert_difference('Facets.registered_facets.count', 1) do
      Facets.register TestFacet
    end
  end

  test 'gives readonly access to the registry' do
    config = {}
    Facets.stubs(:configuration).returns(config)
    Facets.register TestFacet, :test_facet
    assert_difference('Facets.registered_facets.count', 0) do
      Facets.registered_facets.delete(:test_facet)
    end
  end

  context 'single entry' do
    test 'defaults initialization' do
      config = {}
      Facets.stubs(:configuration).returns(config)
      Facets.register TestFacet
      facet_configuration = Facets.registered_facets[:test_facet]
      assert_equal :test_facet, facet_configuration.name
      assert_equal TestFacet, facet_configuration.model
    end

    test 'extended initialization' do
      config = {}
      Facets.stubs(:configuration).returns(config)
      Facets.register TestFacet, :test_model do
        add_helper TestHelper
        extend_model TestExtension
        add_tabs(:a => 'tab_view')
        api_view(:single => 'single_view', :list => 'list_view')
        api_docs(:my_group, TestModel, 'my test description')
        template_compatibility_properties :prop1
      end
      facet_configuration = Facets.registered_facets[:test_model]
      assert_equal :test_model, facet_configuration.name
      assert_equal TestFacet, facet_configuration.model
      assert_equal TestHelper, facet_configuration.helper
      assert_equal TestExtension, facet_configuration.extension
      assert_equal 'single_view', facet_configuration.api_single_view
      assert_equal 'list_view', facet_configuration.api_list_view
      assert_equal 'my test description', facet_configuration.api_param_group_description
      assert_equal :my_group, facet_configuration.api_param_group
      assert_equal TestModel, facet_configuration.api_controller
      assert_equal 'tab_view', facet_configuration.tabs[:a]
      assert_equal [:prop1], facet_configuration.compatibility_properties
    end
  end
end
