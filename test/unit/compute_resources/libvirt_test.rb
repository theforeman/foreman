require 'test_helper'

class LibvirtTest < ActiveSupport::TestCase
  test "#associated_host matches any NIC" do
    host = FactoryGirl.create(:host, :mac => 'ca:d0:e6:32:16:97')
    cr = FactoryGirl.build(:libvirt_cr)
    iface = mock('iface1', :mac => 'ca:d0:e6:32:16:97')
    assert_equal host, as_admin { cr.associated_host(iface) }
  end
end