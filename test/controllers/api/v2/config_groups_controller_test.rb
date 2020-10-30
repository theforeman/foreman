require 'test_helper'

class Api::V2::ConfigGroupsControllerTest < ActionController::TestCase
  test "should not get index" do
    skip('Foreman Puppet Enc plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    get :index, params: { smart_class_parameter_id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access ConfigGroup API, you need to install the Foreman Puppet plugin'
  end

  test "should not get create" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    post :create, params: { smart_class_parameter_id: 213 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access ConfigGroup API, you need to install the Foreman Puppet plugin'
  end

  test "should not show" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    get :show, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access ConfigGroup API, you need to install the Foreman Puppet plugin'
  end

  test "should not update" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    patch :update, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access ConfigGroup API, you need to install the Foreman Puppet plugin'
  end

  test "should not destroy" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    delete :destroy, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access ConfigGroup API, you need to install the Foreman Puppet plugin'
  end
end
