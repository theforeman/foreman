require 'test_helper'
require 'facet_test_helper'

class FacetsHelperTest < ActionView::TestCase
  class TestFacet < HostFacets::Base
  end

  include FacetsHelper

  context 'facets related' do
    setup do
      @facet_model = TestFacet.new
      @host = mock('host')
      @facet_config = Facets::Entry.new(FacetsHelperTest::TestFacet, :test_facet)
      @host.stubs(:facets_with_definitions).returns({ @facet_model => @facet_config })
    end

    teardown do
      Host::Managed.cloned_parameters[:include].delete(:test_facet)
    end

    test '#load_tabs returns hash of facets' do
      expects(:lookup_context).returns(stub(:find_all => ['/some/path/to/template']))
      tabs = facet_tabs(@host)

      assert_equal @facet_model, tabs[:test_facet][:test_facet]
    end

    test '#load_tabs skips facet definition if no template exists' do
      expects(:lookup_context).returns(stub(:find_all => []))
      tabs = facet_tabs(@host)

      assert_nil tabs[:test_facet][:test_facet]
    end

    test '#helper_tabs returns hash if hash specified' do
      @facet_config.add_tabs(:my_new_tab => 'my/tab/template.html.erb')
      tabs = facet_tabs(@host)

      assert_equal 'my/tab/template.html.erb', tabs[:test_facet][:my_new_tab]
    end

    test '#helper_tabs returns hash if method specified' do
      expects(:my_tabs_method).returns({:my_new_tab => 'my/tab/template.html.erb'})
      @facet_config.add_tabs(:my_tabs_method)
      tabs = facet_tabs(@host)

      assert_equal 'my/tab/template.html.erb', tabs[:test_facet][:my_new_tab]
    end
  end
end
