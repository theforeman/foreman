require 'test_helper'

class RackspaceTest < ActiveSupport::TestCase
  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :ip => '10.0.0.154')
    cr = FactoryGirl.build(:rackspace_cr)
    iface = mock('iface1', :public_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
    assert_equal host, as_admin { cr.associated_host(iface) }
  end

  describe "find_vm_by_uuid" do
    before do
      @servers = mock()
      @servers.stubs(:get).returns(nil)

      client = mock()
      client.stubs(:servers).returns(@servers)

      @cr = Foreman::Model::Rackspace.new
      @cr.stubs(:client).returns(client)
    end

    it "raises RecordNotFound when the vm does not exist" do
      assert_raises ActiveRecord::RecordNotFound do
        @cr.find_vm_by_uuid('abc')
      end
    end

    it "raises RecordNotFound when the compute raises rackspace error" do
      @servers.stubs(:get).raises(Fog::Compute::Rackspace::Error)
      assert_raises ActiveRecord::RecordNotFound do
        @cr.find_vm_by_uuid('abc')
      end
    end
  end
end
