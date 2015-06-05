require 'test_helper'

class LibvirtTest < ActiveSupport::TestCase
  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:libvirt_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    assert_equal host, as_admin { cr.associated_host(iface) }
  end

  describe "find_vm_by_uuid" do
    before do
      @servers = mock()
      @servers.stubs(:get).returns(nil)

      client = mock()
      client.stubs(:servers).returns(@servers)

      @cr = Foreman::Model::Libvirt.new
      @cr.stubs(:client).returns(client)
    end

    it "raises RecordNotFound when the vm does not exist" do
      assert_raises ActiveRecord::RecordNotFound do
        @cr.find_vm_by_uuid('abc')
      end
    end

    it "raises RecordNotFound when the compute raises retrieve error" do
      @servers.stubs(:get).raises(Libvirt::RetrieveError)
      assert_raises ActiveRecord::RecordNotFound do
        @cr.find_vm_by_uuid('abc')
      end
    end
  end

  describe "compute_attributes_for" do
    test "returns memory in bytes" do
      vm = mock()
      vm.stubs(:attributes).returns({ :memory_size => 6 })

      cr = FactoryGirl.build(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_equal 6*1024, attrs[:memory]
    end

    test "returns nil memory when :memory_size is not provided" do
      vm = mock()
      vm.stubs(:attributes).returns({})

      cr = FactoryGirl.build(:libvirt_cr)
      cr.stubs(:find_vm_by_uuid).returns(vm)

      attrs = cr.vm_compute_attributes_for('abc')
      assert_equal nil, attrs[:memory]
    end
  end
end
