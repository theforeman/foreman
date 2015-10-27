require 'test_helper'
require 'aspect_test_helper'

class TestAspect < HostAspectBase
end

class HostAspectTest < ActiveSupport::TestCase
  context 'managed host behavior' do
    setup do
      @config = HostAspects::Configuration.new
      HostAspects.stubs(:configuration).returns(@config)
      @config.register 'TestAspect'
      HostAspects::ManagedHostExtensions.refresh_aspect_relations(Host::Managed)

      @host = Host::Managed.new
      @aspect = @host.build_test_aspect
    end

    test 'registered aspects are subscribed properly' do
      assert_equal @aspect, @host.host_aspects.first
    end

    test 'aspects are queried for info' do
      @aspect.expects(:info).returns({:my_fact => :my_value})
      info = @host.info

      assert_equal :my_value, info[:my_fact]
    end

    test 'aspects are notified for facts import' do
      @aspect.class.expects(:populate_fields_from_facts)
      @host.stubs(:save)

      @host.populate_fields_from_facts(:domain => 'example.com',
                                       :operatingsystem => 'RedHat',
                                       :operatingsystemrelease => '6.2',
                                       :macaddress_eth0 => '00:00:11:22:11:22',
                                       :ipaddress_eth0 => '192.168.0.1',
                                       :interfaces => 'eth0')
    end

    test 'aspects are cloned to the new host' do
      aspect_clone = @aspect.dup
      aspect_clone.expects(:after_clone)
      @aspect.stubs(:dup).returns(aspect_clone)

      cloned_host = @host.clone

      assert_equal aspect_clone, cloned_host.test_aspect
      assert_equal aspect_clone, cloned_host.host_aspects.first
    end

    test 'aspects can modify templates selection' do
      @aspect.expects(:template_filter_options).at_least_once.returns({:my_attribute => :my_value})
      ProvisioningTemplate.expects(:find_template).at_least_once.with { |params| params[:my_attribute] == :my_value }.returns([])

      @host.available_template_kinds
    end

    test 'aspects are included in attributes' do
      attributes = @host.attributes

      assert_not_nil attributes["test_aspect_attributes"]
    end
  end
end
