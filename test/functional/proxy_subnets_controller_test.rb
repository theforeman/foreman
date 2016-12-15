require 'test_helper'

class ProxySubnetsControllerTest < ActionController::TestCase
  def setup
    @proxy = smart_proxies(:one)
    @subnet_details = { :network => "192.168.100.0",
                        :netmask => "255.255.255.0",
                        :leases => [],
                        :reservations => [{ "hostname" => "host.example.com", "ip" => "192.168.100.25", "mac" => "52:54:00:cb:c4:0b" }]}
    @details = Net::DHCP::Subnet.new @subnet_details
  end

  test "should get index" do
    subnets = [{ :network => "192.168.111.0", :netmask => "255.255.255.0"},
               { :network => "192.168.222.0", :netmask => "255.255.255.0"}]
    subnets = subnets.map { |s| Net::DHCP::Subnet.new s }
    ProxyStatus::DHCP.any_instance.stubs(:subnets).returns(subnets)
    get :index, { :smart_proxy_id => @proxy.id }, set_session_user
    assert @response.ok?
    assert_template 'smart_proxies/plugins/_dhcp_subnets'
    assert @response.body.match(/192.168.111.0/)
  end

  test "should get network details" do
    ProxyStatus::DHCP.any_instance.stubs(:subnet).returns(@details)
    get :show, { :smart_proxy_id => @proxy.id,
                 :id => @proxy.id,
                 :dhcp_subnet => {
                   :network => @subnet_details[:network],
                   :netmask => @subnet_details[:netmask] }
               }, set_session_user
    assert @response.ok?
    assert_template 'smart_proxies/plugins/_dhcp_subnet_show'
    assert @response.body.match(/192.168.100.25/)
  end

  test "should delete record from proxy" do
    Net::DHCP::Record.any_instance.stubs(:destroy).returns(true)
    proxy = FactoryGirl.create(:dhcp_smart_proxy)
    ProxyStatus::DHCP.any_instance.stubs(:subnet).returns(@details)
    ProxyStatus::DHCP.any_instance.stubs(:revoke_cache!)
    delete :destroy, { :smart_proxy_id => proxy.id,
                       :dhcp_subnet => @subnet_details,
                       :id => 0,
                       :record => {
                         :hostname => "host.example.com",
                         :ip => "192.168.100.120",
                         :mac => "52:54:00:ad:6f:38",
                         :network => "192.168.100.0" }
                     }, set_session_user
    assert @response.ok?
    assert_template 'smart_proxies/plugins/_dhcp_subnet_show'
  end
end
