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

  context "managed host facet behavior" do
    setup do
      TestFacet.class_eval do
        def my_attribute
        end

        def my_attribute=(val)
        end
      end

      Facets.register TestFacet
    end

    test 'facets are updated without specifying id explicitly' do
      saved_host = FactoryGirl.create(:host)
      saved_host.build_test_facet
      saved_host.save!
      saved_host.attributes = {'test_facet_attributes' => { 'my_attribute' => 'my_value'}}
      assert_not_nil saved_host.test_facet.id
    end

    test 'facets do not get created for nil attributes and viceversa' do
      saved_host = FactoryGirl.build(:host)

      saved_host.update_attributes({'test_facet_attributes' => { 'my_attribute' => nil}})
      assert_nil saved_host.test_facet

      saved_host.update_attributes({'test_facet_attributes' => { 'my_attribute' => "val"}})
      assert_not_nil saved_host.test_facet
    end
  end
end
