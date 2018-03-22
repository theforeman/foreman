require 'test_helper'

class Api::V2::AuthSourceLdapsControllerTest < ActionController::TestCase
  valid_attrs = { :name => 'ldap2', :host => 'ldap2', :server_type => 'posix' }

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:auth_source_ldaps)
    auth_source_ldaps = ActiveSupport::JSON.decode(@response.body)
    assert !auth_source_ldaps.empty?
  end

  test "should show auth_source_ldap" do
    get :show, params: { :id => auth_sources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create auth_source_ldap" do
    assert_difference('AuthSourceLdap.unscoped.count', 1) do
      post :create, params: { :auth_source_ldap => valid_attrs }
    end
    assert_response :created
  end

  test "should update auth_source_ldap" do
    put :update, params: { :id => auth_sources(:one).to_param, :auth_source_ldap => valid_attrs }
    assert_response :success
  end

  test "should destroy auth_source_ldap" do
    assert_difference('AuthSourceLdap.unscoped.count', -1) do
      auth = auth_sources(:one)
      User.where(:auth_source_id => auth.id).update_all(:auth_source_id => nil)
      delete :destroy, params: { :id => auth.id }
    end
    assert_response :success
  end

  test "LDAP testing success" do
    AuthSourceLdap.any_instance.stubs(:test_connection).returns(:message => 'success')
    put :test, params: { :id => auth_sources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "LDAP testing failed" do
    AuthSourceLdap.any_instance.stubs(:test_connection).raises(Foreman::Exception)
    put :test, params: { :id => auth_sources(:one).to_param }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response[:success]
  end

  # This controller overrides 'controller_permission' in order to use
  # view_authenticators (& friends) instead of view_auth_source_ldaps
  context '*_authenticators filters' do
    test 'restrict access to authenticators properly' do
      setup_user('view', 'auth_source_ldaps')
      get :index
      assert_response :forbidden
    end

    test 'allow access to auth source LDAP objects' do
      setup_user('view', 'authenticators')
      get :show, params: { :id => auth_sources(:one).to_param }
      assert_response :success
    end
  end

  test 'taxonomies can be set' do
    put :update, params: { :id => auth_sources(:one).to_param,
                           :organization_names => [taxonomies(:organization1).name],
                           :location_ids => [taxonomies(:location1).id] }
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal taxonomies(:location1).id,
      show_response['locations'].first['id']
    assert_equal taxonomies(:organization1).id,
      show_response['organizations'].first['id']
  end
end
