require 'test_helper'

class Api::V2::PuppetclassesControllerTest < ActionController::TestCase
  [{}, { host_id: 123 }, { hostgroup_id: 123 }, { environment_id: 123 }].each do |params|
    test "should not get index with #{params.inspect}" do
      skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
      get :index, params: params
      assert_response :not_implemented
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal response['message'], 'To access Puppetclass API, you need to install the Foreman Puppet plugin'
    end

    test "should not show" do
      skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
      get :show, params: params.merge(id: 121)
      assert_response :not_implemented
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal response['message'], 'To access Puppetclass API, you need to install the Foreman Puppet plugin'
    end
  end

  test "should not create" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    patch :create, params: { name: 'PuppetClassName' }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Puppetclass API, you need to install the Foreman Puppet plugin'
  end

  test "should not update" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    patch :update, params: { id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Puppetclass API, you need to install the Foreman Puppet plugin'
  end

  test "should not destroy" do
    skip('Foreman Puppet plugin is installed') if Foreman::Plugin.find(:foreman_puppet)
    delete :destroy, params: { id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access Puppetclass API, you need to install the Foreman Puppet plugin'
  end
end
