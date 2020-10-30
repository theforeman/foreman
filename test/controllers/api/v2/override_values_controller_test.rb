require 'test_helper'

class Api::V2::OverrideValuesControllerTest < ActionController::TestCase
  test "should not get index" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    get :index, params: { smart_class_parameter_id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Override Value API, you need to install the Foreman Puppet plugin'
  end

  test "should not get create" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    post :create, params: { smart_class_parameter_id: 213 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Override Value API, you need to install the Foreman Puppet plugin'
  end

  test "should not show" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    get :show, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Override Value API, you need to install the Foreman Puppet plugin'
  end

  test "should not update" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    patch :update, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Override Value API, you need to install the Foreman Puppet plugin'
  end

  test "should not destroy" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    delete :destroy, params: { smart_class_parameter_id: 213, id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Override Value API, you need to install the Foreman Puppet plugin'
  end
end
