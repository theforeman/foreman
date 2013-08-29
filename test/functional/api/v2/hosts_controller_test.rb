require 'test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase
  test "should run puppet for specific host" do
    any_instance_of(ProxyAPI::Puppet) do |klass|
      stub(klass).run { true }
    end
    get :puppetrun, { :id => hosts(:one).to_param }
    assert_response :success
  end

  context 'BMC proxy operations' do
    setup :initialize_proxy_ops

    def initialize_proxy_ops
      User.current = users(:apiadmin)
      nics(:bmc).update_attribute(:host_id, hosts(:one).id)
    end

    test "power call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:power).with(:action => 'status').returns("on")
      put :power, { :id => hosts(:one).to_param, :power_action => 'status' }
      assert_response :success
      assert @response.body =~ /on/
    end

    test "wrong power call fails gracefully" do
      put :power, { :id => hosts(:one).to_param, :power_action => 'wrongmethod' }
      assert_response 422
      assert @response.body =~ /Available methods are/
    end

    test "boot call to interface" do
      ProxyAPI::BMC.any_instance.stubs(:boot).with(:function => 'bootdevice', :device => 'bios').
                                              returns( { "action" => "bios", "result" => true } .to_json)
      put :boot, { :id => hosts(:one).to_param, :device => 'bios' }
      assert_response :success
      assert @response.body =~ /true/
    end

    test "wrong boot call to interface fails gracefully" do
      put :boot, { :id => hosts(:one).to_param, :device => 'wrongbootdevice' }
      assert_response 422
      assert @response.body =~ /Available devices are/
    end

  end

end
