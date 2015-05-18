require 'test_helper'

class Api::V2::ExternalUsergroupsControllerTest < ActionController::TestCase
  setup do
    ExternalUsergroup.any_instance.stubs(:in_auth_source?).returns(true)
    @external_usergroup = FactoryGirl.create(:external_usergroup)
  end

  test 'external user groups in user group' do
    get :index, { :usergroup_id => @external_usergroup.usergroup_id }
    assert_response :success
    assert_not_nil assigns(:external_usergroups)
    refute_empty ActiveSupport::JSON.decode(@response.body)['results']
  end

  test 'show an external user group' do
    get :show, { :usergroup_id => @external_usergroup.usergroup_id,
                 :id           => @external_usergroup.id }
    assert_response :success
    refute_empty ActiveSupport::JSON.decode(@response.body)
  end

  test 'create external user group' do
    usergroup   = FactoryGirl.create(:usergroup)
    auth_source = FactoryGirl.create(:auth_source_ldap)
    valid_attrs = { 'name' => 'foremanusergroup', 'auth_source_id' => auth_source.id }
    ExternalUsergroup.any_instance.expects(:refresh).returns(true)
    assert_difference('usergroup.external_usergroups.count') do
      post :create, { :usergroup_id       => usergroup.to_param,
                      :external_usergroup => valid_attrs }
    end
    assert_response :success
  end

  test 'refresh external user group' do
    ExternalUsergroup.any_instance.expects(:users).returns([])
    put :refresh, { :usergroup_id => @external_usergroup.usergroup_id,
                    :id           => @external_usergroup.id }
    assert_response :success
  end

  test 'update a external user group' do
    ExternalUsergroup.any_instance.expects(:refresh).returns(true)
    valid_attrs = { 'name' => 'foremanusergroup' }
    put :update, { :usergroup_id => @external_usergroup.usergroup_id,
                   :id => @external_usergroup.id,
                   :external_usergroup => valid_attrs }
    assert_response :success
    assert_equal ExternalUsergroup.find(@external_usergroup.id).name, valid_attrs['name']
  end

  test 'destroy external user group' do
    ExternalUsergroup.any_instance.expects(:refresh).returns(true)
    assert_difference('ExternalUsergroup.count', -1) do
      delete :destroy, { :usergroup_id => @external_usergroup.usergroup_id,
                         :id           => @external_usergroup.id }
    end
    assert_response :success
  end
end
