require 'test_helper'

class VmwareTest < ActiveSupport::TestCase
  test "#create_vm calls new_vm when network provisioning" do
    interfaces_attributes = { "new_interfaces" => { "type" => "VirtualE1000",   "network" => "network-17", "_delete" => ""},
                              "0"              => { "type" => "VirtualVmxnet3", "network" => "network-17", "_delete" => ""}}
    volumes_attributes    = { "new_volumes" => { "size_gb" => "10", "_delete" => ""},
                              "0"           => { "size_gb" => "1",  "_delete" => ""}}

    attrs_in = HashWithIndifferentAccess.new("cpus"                  => "1",
                                             "interfaces_attributes" => interfaces_attributes,
                                             "volumes_attributes"    => volumes_attributes)

    attrs_parsed = HashWithIndifferentAccess.new("cpus"                  => "1",
                                                 "interfaces_attributes" => {"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "_delete"=>""},
                                                                            "0" => {"type"=>"VirtualVmxnet3", "network"=>"Test network", "_delete"=>""}},
                                                 "volumes_attributes"    => {"new_volumes"=>{"size_gb"=>"10", "_delete"=>""},
                                                                             "0"=>{"size_gb"=>"1", "_delete"=>""}})

    mock_vm = mock('vm')
    mock_vm.expects(:save).returns(mock_vm)

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:new_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  test "#new_vm merges defaults with user args and creates server" do
    attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    attrs_parsed = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
    attrs_out = {:name => 'test', :cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}

    mock_vm = mock('new server')
    mock_servers = mock('client.servers')
    mock_servers.expects(:new).with(attrs_out).returns(mock_vm)
    mock_client = mock('client')
    mock_client.expects(:servers).returns(mock_servers)

    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_args).with(attrs_in).returns(attrs_parsed)
    cr.expects(:vm_instance_defaults).returns(HashWithIndifferentAccess.new(:name => 'test', :cpus => '2', :interfaces => [mock('iface')], :volumes => [mock('vol')]))
    cr.expects(:client).returns(mock_client)
    assert_equal mock_vm, cr.new_vm(attrs_in)
  end

  test "#create_vm calls clone_vm when image provisioning" do
    attrs_in = HashWithIndifferentAccess.new("image_id"=>"2","cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
    attrs_parsed = HashWithIndifferentAccess.new("image_id"=>"2","cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"Test network", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})

    mock_vm = mock('vm')
    cr = FactoryGirl.build(:vmware_cr)
    cr.expects(:parse_networks).with(attrs_in).returns(attrs_parsed)
    cr.expects(:clone_vm).with(attrs_parsed).returns(mock_vm)
    cr.expects(:test_connection)
    assert_equal mock_vm, cr.create_vm(attrs_in)
  end

  describe "#parse_args" do
    setup do
      @cr = FactoryGirl.build(:vmware_cr)
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_args(HashWithIndifferentAccess.new))
    end

    test "converts form attrs to fog attrs" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      # All keys must be symbolized
      attrs_out = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is ommiting hardware_version, when it's set to Default" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "hardware_version"=>"Default", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      attrs_out = {:cpus=>"1", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "is setting hardware_version, when it's set to a non-Default value" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "hardware_version"=>"vmx-08", "interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}}, "volumes_attributes"=>{"new_volumes"=>{"size_gb"=>"10", "_delete"=>""}, "0"=>{"size_gb"=>"1", "_delete"=>""}})
      attrs_out = {:cpus=>"1", :hardware_version=>"vmx-08", :interfaces=>[{:type=>"VirtualVmxnet3", :network=>"network-17", :_delete=>""}], :volumes=>[{:size_gb=>"1", :_delete=>""}]}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "converts scsi_controller_type to hash" do
      attrs_in = HashWithIndifferentAccess.new("cpus"=>"1", "scsi_controller_type"=>"ParaVirtualSCSIController", "interfaces_attributes"=>{}, "volumes_attributes"=>{})
      attrs_out = {:cpus=>"1", :interfaces=>[], :volumes=>[], :scsi_controller=>{:type=>"ParaVirtualSCSIController"}}
      assert_equal attrs_out, @cr.parse_args(attrs_in)
    end

    test "doesn't modify input hash" do
      # else compute profiles won't save properly
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"0"=>{"network"=>"network-17"}})
      @cr.parse_args(attrs_in)
      assert_equal "network-17", attrs_in["interfaces_attributes"]["0"]["network"]
    end
  end

  describe "#parse_networks" do
    setup do
      @mock_network = mock('network')
      @mock_network.stubs('id').returns('network-17')
      @mock_network.stubs('name').returns('Test network')
      @cr = FactoryGirl.build(:vmware_cr)
      @cr.stubs(:networks).returns([@mock_network])
    end

    test "converts empty hash" do
      assert_equal({}, @cr.parse_networks(HashWithIndifferentAccess.new))
    end

    test "converts form network ID to network name" do
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"network-17", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"network-17", "_delete"=>""}})
      attrs_out = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"Test network", "_delete"=>""}})
      assert_equal attrs_out, @cr.parse_networks(attrs_in)
    end

    test "ignores existing network names" do
      attrs = HashWithIndifferentAccess.new("interfaces_attributes"=>{"new_interfaces"=>{"type"=>"VirtualE1000", "network"=>"Test network", "_delete"=>""}, "0"=>{"type"=>"VirtualVmxnet3", "network"=>"Test network", "_delete"=>""}})
      assert_equal attrs, @cr.parse_networks(attrs)
    end

    test "doesn't modify input hash" do
      # else compute profiles won't save properly
      attrs_in = HashWithIndifferentAccess.new("interfaces_attributes"=>{"0"=>{"network"=>"network-17"}})
      @cr.parse_args(attrs_in)
      assert_equal "network-17", attrs_in["interfaces_attributes"]["0"]["network"]
    end
  end
end
