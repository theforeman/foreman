require 'test_helper'

class TestFacet < HostFacets::Base
end

module TestModule
  class ModuleTestFacet < HostFacets::Base
  end
end

class FacetTest < ActiveSupport::TestCase
  setup do
    @config = {}
    Facets.stubs(:configuration).returns(@config)
  end

  teardown do
    Host::Managed.cloned_parameters[:include].delete(:test_model)
    Host::Managed.cloned_parameters[:include].delete(:test_facet)
    Host::Managed.cloned_parameters[:include].delete(:namespaced_facet)
  end

  context 'namespaced facets' do
    setup do
      Facets.register TestModule::ModuleTestFacet, :namespaced_facet

      @host = Host::Managed.new
      @facet = @host.build_namespaced_facet
    end

    test 'can create a namespaced facet' do
      assert_equal @facet, @host.facets.first
    end

    test 'returns facets attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["namespaced_facet_attributes"]
    end
  end

  context 'managed host behavior' do
    setup do
      Facets.register TestFacet

      @host = Host::Managed.new
      @facet = @host.build_test_facet
    end

    test 'registered facets are subscribed properly' do
      assert_equal @facet, @host.facets.first
    end

    test 'facets are cloned to the new host' do
      facet_clone = @facet.dup
      @facet.stubs(:dup).returns(facet_clone)

      cloned_host = @host.clone

      assert_equal facet_clone, cloned_host.test_facet
      assert_equal facet_clone, cloned_host.facets.first
    end

    test 'facets are included in attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["test_facet_attributes"]
    end
  end
end
