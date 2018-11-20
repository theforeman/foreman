require 'test_helper'

class ComputeResourceHostImporterTest < ActiveSupport::TestCase
  setup { Fog.mock! }
  teardown { Fog.unmock! }

  let(:importer) do
    ComputeResourceHostImporter.new(
      :compute_resource => compute_resource,
      :vm => vm
    )
  end
  let(:host) { importer.host }
  let(:vm) { compute_resource.find_vm_by_uuid(uuid) }

  context 'on vmware' do
    let(:compute_resource) do
      cr = FactoryBot.create(:compute_resource, :vmware, :uuid => 'Solutions')
      ComputeResource.find_by_id(cr.id)
    end
    let(:uuid) { '5032c8a5-9c5e-ba7a-3804-832a03e16381' }

    context 'with existing domain' do
      setup do
        @domain = FactoryBot.create(:domain, :name => 'virt.bos.redhat.com')
      end

      test 'imports the VM with all parameters' do
        expected_compute_attributes = {
          'network' => 'network1',
          'type' => 'VirtualE1000'
        }

        assert_equal 'dhcp75-197', host.name
        assert_equal uuid, host.uuid
        assert_equal @domain, host.domain
        assert_equal '00:50:56:a9:00:28', host.mac
        assert_equal expected_compute_attributes, host.primary_interface.compute_attributes
        assert_equal false, host.build
        assert_equal compute_resource, host.compute_resource
      end
    end

    context 'without existing domain' do
      test 'creates the domain' do
        assert_equal 'dhcp75-197', host.name
        domain = Domain.find_by_name('virt.bos.redhat.com')
        assert_kind_of Domain, domain
        assert_equal domain, host.domain
      end

      test 'does not create an invalid domain' do
        Fog::Compute::Vsphere::Server.any_instance.stubs(:name).returns('mytestvm')
        Fog::Compute::Vsphere::Server.any_instance.stubs(:hostname).returns(nil)
        assert_equal 'mytestvm', host.name
        assert_nil host.domain
      end
    end
  end

  context 'on libvirt' do
    let(:compute_resource) { FactoryBot.build(:libvirt_cr) }
    let(:uuid) { 'fog-449765558356062' }

    test 'imports the VM with all parameters' do
      assert_equal 'fog-dom1', host.name
      assert_equal 'dom.uuid', host.uuid
      assert_nil host.domain
      assert_equal 'aa:bb:cc:dd:ee:ff', host.mac
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end

  context 'on ec2' do
    let(:compute_resource) { FactoryBot.build(:ec2_cr) }
    let(:vm) { compute_resource.send(:client).servers.new }
    setup do
      vm.save
    end

    test 'imports the VM with all parameters' do
      assert_equal vm.identity, host.name
      assert_equal vm.identity, host.uuid
      assert_nil host.domain
      assert_nil host.mac
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end

  context 'on gce' do
    let(:compute_resource) { compute_resources(:gce) }
    let(:vm) { compute_resource.vms.first }

    test 'imports the VM with all parameters' do
      assert_equal vm.identity, host.name
      assert_nil host.domain
      assert_nil host.mac
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end

  context 'on openstack' do
    let(:compute_resource) { FactoryBot.build(:openstack_cr) }
    let(:compute) { compute_resource.send(:client) }
    let(:flavor) { compute.flavors.first.id }
    let(:os_image) { compute.images.first.id }
    let(:floating_ip) do
      compute.allocate_address('f0000000-0000-0000-0000-000000000000').body["floating_ip"]["ip"].to_s
    end
    let(:vm) do
      compute.servers.new(
        :name       => 'test.example.com',
        :flavor_ref => flavor,
        :image_ref  => os_image
      )
    end
    setup do
      @domain = FactoryBot.create(:domain, :name => 'example.com')
      vm.save
      vm.associate_address(floating_ip)
      vm.reload
    end

    test 'imports the VM with all parameters' do
      assert_equal 'test', host.name
      assert_equal vm.identity, host.uuid
      assert_equal @domain, host.domain
      assert_equal floating_ip, host.ip
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end

  context 'on ovirt' do
    let(:compute_resource) { FactoryBot.build(:ovirt_cr) }
    let(:uuid) { '52b9406e-cf66-4867-8655-719a094e324c' }

    test 'imports the VM with all parameters' do
      assert_equal 'vm01', host.name
      assert_equal uuid, host.uuid
      assert_nil host.domain
      assert_equal '00:1a:4a:23:1b:8f', host.mac
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end

  context 'on rackspace' do
    let(:compute_resource) { FactoryBot.build(:rackspace_cr) }
    let(:uuid) { '52b9406e-cf66-4867-8655-719a094e324c' }
    let(:compute) { compute_resource.send(:client) }
    let(:flavor) { compute.flavors.first.id }
    let(:os_image) { compute.images.first.id }
    let(:vm) do
      compute.servers.new(
        :name         => 'test.example.com',
        :flavor_id    => flavor,
        :image_id     => os_image,
        :ipv4_address => '192.168.100.1',
        :ipv6_address => '2001:db8::1'
      )
    end
    setup do
      @domain = FactoryBot.create(:domain, :name => 'example.com')
      vm.save
    end

    test 'imports the VM with all parameters' do
      assert_equal 'test', host.name
      assert_equal vm.id, host.uuid
      assert_equal @domain, host.domain
      assert_nil host.mac
      assert_equal '192.168.100.1', host.ip
      assert_equal '2001:db8::1', host.ip6
      assert_empty host.primary_interface.compute_attributes
      assert_equal compute_resource, host.compute_resource
    end
  end
end
