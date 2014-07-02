require 'test_helper'

class OvirtTest < ActiveSupport::TestCase
  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:ovirt_cr)
    iface1 = mock('iface1', :mac => '36:48:c5:c9:86:f2')
    iface2 = mock('iface2', :mac => 'ca:d0:e6:32:16:97')
    vm = mock('vm', :interfaces => [iface1, iface2])
    assert_equal host, as_admin { cr.associated_host(vm) }
  end
end
