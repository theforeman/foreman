require 'test_helper'

class Api::V2::HostClassesControllerTest < ActionController::TestCase
  test "should not get index" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    get :index, params: { host_id: 123 }
    assert_response :not_implemented
    json_response = ActiveSupport::JSON.decode(response.body)
    assert_equal json_response['message'], 'To access HostClass API, you need to install the Foreman Puppet plugin'
  end

  test "should not show" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    get :create, params: { host_id: 123 }
    assert_response :not_implemented
    json_response = ActiveSupport::JSON.decode(response.body)
    assert_equal json_response['message'], 'To access HostClass API, you need to install the Foreman Puppet plugin'
  end

  test "should not update" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    patch :destroy, params: { host_id: 123, id: 124 }
    assert_response :not_implemented
    json_response = ActiveSupport::JSON.decode(response.body)
    assert_equal json_response['message'], 'To access HostClass API, you need to install the Foreman Puppet plugin'
  end
end
