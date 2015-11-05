require 'test_helper'
require 'facet_test_helper'

class TestFacet < HostFacetBase
end

class FacetTest < ActiveSupport::TestCase
  context 'managed host behavior' do
    setup do
      @config = Facets::Configuration.new
      Facets.stubs(:configuration).returns(@config)
      @config.register 'TestFacet'
      Facets::ManagedHostExtensions.refresh_facet_relations(Host::Managed)

      @host = Host::Managed.new
      @facet = @host.build_test_facet
    end

    test 'registered facets are subscribed properly' do
      assert_equal @facet, @host.host_facets.first
    end

    test 'facets are queried for info' do
      @facet.expects(:info).returns({:my_fact => :my_value})
      info = @host.info

      assert_equal :my_value, info[:my_fact]
    end

    test 'facets are notified for facts import' do
      @facet.class.expects(:populate_fields_from_facts)
      @host.stubs(:save)

      @host.populate_fields_from_facts(:domain => 'example.com',
                                       :operatingsystem => 'RedHat',
                                       :operatingsystemrelease => '6.2',
                                       :macaddress_eth0 => '00:00:11:22:11:22',
                                       :ipaddress_eth0 => '192.168.0.1',
                                       :interfaces => 'eth0')
    end

    test 'facets are cloned to the new host' do
      facet_clone = @facet.dup
      facet_clone.expects(:after_clone)
      @facet.stubs(:dup).returns(facet_clone)

      cloned_host = @host.clone

      assert_equal facet_clone, cloned_host.test_facet
      assert_equal facet_clone, cloned_host.host_facets.first
    end

    test 'facets can modify templates selection' do
      @facet.expects(:template_filter_options).at_least_once.returns({:my_attribute => :my_value})
      ProvisioningTemplate.expects(:find_template).at_least_once.with { |params| params[:my_attribute] == :my_value }.returns([])

      @host.available_template_kinds
    end

    test 'facets are included in attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["test_facet_attributes"]
    end
  end
end
