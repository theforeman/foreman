require 'test_helper'

class Api::V2::AuthSourceLdapsControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'ldap2', :host => 'ldap2', :server_type => 'posix' }

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:auth_source_ldaps)
    auth_source_ldaps = ActiveSupport::JSON.decode(@response.body)
    assert !auth_source_ldaps.empty?
  end

  test "should show auth_source_ldap" do
    get :show, { :id => auth_sources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create auth_source_ldap" do
    assert_difference('AuthSourceLdap.count', 1) do
      post :create, { :auth_source_ldap => valid_attrs }
    end
    assert_response :success
  end

  test "should update auth_source_ldap" do
    put :update, { :id => auth_sources(:one).to_param, :auth_source_ldap => valid_attrs }
    assert_response :success
  end

  test "should destroy auth_source_ldap" do
    assert_difference('AuthSourceLdap.count', -1) do
      auth = auth_sources(:one)
      User.where(:auth_source_id => auth.id).update_all(:auth_source_id => nil)
      delete :destroy, { :id => auth.id }
    end
    assert_response :success
  end
end
