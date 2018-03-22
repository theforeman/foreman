require 'test_helper'

class Api::V2::PuppetHostsControllerTest < ActionController::TestCase
  test 'puppetrun routes to /host/:id/puppetrun' do
    assert_routing(
      { method: 'put', path: '/api/hosts/zzz.com/puppetrun' },
      { "format"=>"json", "apiv"=>"v2", controller: "api/v2/puppet_hosts", action: "puppetrun", id: "zzz.com" },
      { "format"=>"json", "apiv"=>"v2" })
  end

  test "should run puppet for specific host" do
    as_admin { @phost = FactoryBot.create(:host, :with_puppet) }
    User.current=nil
    ProxyAPI::Puppet.any_instance.stubs(:run).returns(true)
    put :puppetrun, params: { :controller => 'puppet_hosts', :id => @phost.id }
    assert_response :success
  end
end
