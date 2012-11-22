require 'test_helper'

class Api::V1::AuthSourceLdapsControllerTest < ActionController::TestCase

  valid_attrs = { :name => 'ldap2', :host => 'ldap2' }

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
    put :update, { :id => auth_sources(:one).to_param, :auth_source_ldap => { } }
    assert_response :success
  end

  test "should destroy auth_source_ldap" do
    assert_difference('AuthSourceLdap.count', -1) do
      delete :destroy, { :id => auth_sources(:one).to_param }
    end
    assert_response :success
  end

end
