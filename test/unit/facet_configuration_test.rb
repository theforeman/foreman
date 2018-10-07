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

  setup do
    # Do not mess with the Host::Managed object as
    # we just want to test the configuration here
    Host::Managed.stubs(:register_facet_relation)
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
    setup do
      config = {}
      Facets.stubs(:configuration).returns(config)
      Facets.register TestFacet
      facet_configuration = Facets.registered_facets[:test_facet]
      assert_equal :test_facet, facet_configuration.name
      assert_equal TestFacet, facet_configuration.model
    end

    context 'compatibility pass through to host' do
      test 'defaults initialization' do
        Facets.register TestFacet
        facet_configuration = Facets.registered_facets[:test_facet]
        assert_equal :test_facet, facet_configuration.name
        assert_equal TestFacet, facet_configuration.model
      end

      test 'extended initialization' do
        Facets.register TestFacet, :test_model do
          add_helper TestHelper
          extend_model TestExtension
          add_tabs(:a => 'tab_view')
          api_view(:single => 'single_view', :list => 'list_view')
          api_docs(:my_group, TestModel, 'my test description')
          template_compatibility_properties :prop1
          set_dependent_action :restrict_with_exception
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
        assert_equal :restrict_with_exception, facet_configuration.dependent
      end
    end

    context 'host facet configuration' do
      test 'name only' do
        entry = Facets.register :test_facet do
          configure_host TestFacet
        end

        assert_equal entry, Facets.registered_facets[:test_facet]
        assert entry.has_host_configuration?
        refute entry.has_hostgroup_configuration?
        assert_equal TestFacet, entry.host_configuration.model
      end

      test 'no class generates an error' do
        Host::Managed.unstub(:register_facet_relation)
        assert_raises NoMethodError do
          Facets.register :test_facet do
            configure_host
          end
        end
      end

      test 'class only' do
        entry = Facets.register TestFacet do
          configure_host
        end
        assert_equal entry, Facets.registered_facets[:test_facet]
        assert entry.has_host_configuration?
        refute entry.has_hostgroup_configuration?
        assert_equal :test_facet, entry.name
      end

      test 'extended initialization' do
        Facets.register TestFacet, :test_model do
          configure_host do
            add_helper TestHelper
            extend_model TestExtension
            add_tabs(:a => 'tab_view')
            api_view(:single => 'single_view', :list => 'list_view')
            api_docs(:my_group, TestModel, 'my test description')
            template_compatibility_properties :prop1
            set_dependent_action :restrict_with_exception
          end
        end

        facet_configuration = Facets.registered_facets[:test_model].host_configuration
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
        assert_equal :restrict_with_exception, facet_configuration.dependent
      end
    end
  end
end
