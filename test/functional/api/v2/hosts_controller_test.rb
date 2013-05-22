require 'test_helper'

class Api::V2::HostsControllerTest < ActionController::TestCase

  test "should run puppet for specific host" do
    any_instance_of(ProxyAPI::Puppet) do |klass|
      stub(klass).run { true }
    end
    get :puppetrun, { :id => hosts(:one).to_param }
    assert_response :success
  end

end
