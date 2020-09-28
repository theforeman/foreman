require 'test_helper'

class Api::V2::SmartClassParametersControllerTest < ActionController::TestCase
  [{}, { host_id: 123 }, { hostgroup_id: 123 }, { puppetclass_id: 123 },
   { environment_id: 123 }, { puppetclass_id: 123, environment_id: 124 }].each do |params|
    test "should not get index with #{params.inspect}" do
      skip('Foreman Puppet Enc plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
      get :index, params: params
      assert_response :not_implemented
      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal response['message'], 'To access SmartClassParameters API you need to install Foreman Puppet Enc plugin'
    end
  end

  test "should not show" do
    skip('Foreman Puppet Enc plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    get :show, params: { id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access SmartClassParameters API you need to install Foreman Puppet Enc plugin'
  end

  test "should not update" do
    skip('Foreman Puppet Enc plugin is installed') if Foreman::Plugin.find(:foreman_puppet_enc)
    patch :update, params: { id: 123 }
    assert_response :not_implemented
    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal response['message'], 'To access SmartClassParameters API you need to install Foreman Puppet Enc plugin'
  end
end
