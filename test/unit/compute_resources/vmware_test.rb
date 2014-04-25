require 'test_helper'

class VmwareTest < ActiveSupport::TestCase
  test "#create_vm calls new_vm when network provisioning" do
    attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    # All keys must be symbolized
    attrs_out = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"Test network", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}

    mock_vm = mock('vm')
    mock_vm.expects(:save).returns(mock_vm)
    mock_network = mock('network')
    mock_network.stubs('id').returns('network-17')
    mock_network.stubs('name').returns('Test network')

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:new_vm).with(attrs_out).returns(mock_vm)
    cr.expects(:test_connection)
    cr.expects(:networks).returns([mock_network])
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  test "#new_vm merges defaults with user args and creates server" do
    attrs_in = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"Test network", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
    attrs_out = {:name => 'test', :cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"Test network", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}

    mock_vm = mock('new server')
    mock_servers = mock('client.servers')
    mock_servers.expects(:new).with(attrs_out).returns(mock_vm)
    mock_client = mock('client')
    mock_client.expects(:servers).returns(mock_servers)

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:vm_instance_defaults).returns(HashWithIndifferentAccess.new(:name => 'test', :cpus => '2', :interfaces => [mock('iface')], :volumes => [mock('vol')]))
    cr.expects(:client).returns(mock_client)
    assert_equal mock_vm, cr.new_vm(attrs_in)
  end

  test "#create_vm calls clone_vm when image provisioning" do
    attrs_in = HashWithIndifferentAccess.new("image_id"=>"2","cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    # All keys must be symbolized
    attrs_out = {:image_id=>"2", :cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"Test network", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}

    mock_vm = mock('vm')
    mock_network = mock('network')
    mock_network.stubs('id').returns('network-17')
    mock_network.stubs('name').returns('Test network')

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:clone_vm).with(attrs_out).returns(mock_vm)
    cr.expects(:test_connection)
    cr.expects(:networks).returns([mock_network])
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end
end
