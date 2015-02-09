require 'test_helper'

class OpenstackTest < ActiveSupport::TestCase
  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :ip => '10.0.0.154')
    cr = FactoryGirl.build(:openstack_cr)
    iface = mock('iface1', :floating_ip_address => '10.0.0.154', :private_ip_address => "10.1.1.1")
    assert_equal host, as_admin { cr.associated_host(iface) }
  end
end