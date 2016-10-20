require 'test_helper'

class AuthSourceLdapsControllerTest < ActionController::TestCase
  setup do
    @model = AuthSourceLdap.unscoped.first
  end

  basic_index_test
  basic_new_test
  basic_edit_test

  def test_create_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    post :create, {:auth_source_ldap => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    post :create, {:auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name}}, set_session_user
    assert_redirected_to auth_source_ldaps_url
  end

  def test_update_invalid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => AuthSourceLdap.unscoped.first, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_template 'edit'
  end

  def test_formats_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => AuthSourceLdap.unscoped.first.id, :format => "weird", :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_response :success

    wierd_id = "#{AuthSourceLdap.unscoped.first.id}.weird"
    put :update, {:id => wierd_id, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_response :success

    parameterized_id = "#{AuthSourceLdap.unscoped.first.id}-#{AuthSourceLdap.unscoped.first.name.parameterize}"
    put :update, {:id => parameterized_id, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_response :success
  end

  def test_update_valid
    AuthSourceLdap.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => AuthSourceLdap.unscoped.first, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_redirected_to auth_source_ldaps_url
  end

  def test_destroy
    auth_source_ldap = AuthSourceLdap.unscoped.first
    User.unscoped.where(:auth_source_id => auth_source_ldap.id).update_all(:auth_source_id => nil)
    delete :destroy, {:id => auth_source_ldap}, set_session_user
    assert_redirected_to auth_source_ldaps_url
    refute AuthSourceLdap.unscoped.exists?(auth_source_ldap.id)
  end

  context 'user with viewer rights' do
    # The 'Viewer' role has '*_authenticators' filters, so these tests test
    # the override of 'controller_name' to 'authorizers' instead of
    # '*_auth_source_ldaps' permissions

    setup do
      @request.session[:user] = users(:one).id
      users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
    end

    test 'should fail to edit authentication source' do
      get :edit, { :id => AuthSourceLdap.unscoped.first.id },
        set_session_user(users(:one))
      assert_response :forbidden
      assert_includes @response.body, 'edit_authenticators'
    end
  end

  test "blank account_password submitted does not erase existing account_password" do
    auth_source_ldap = AuthSourceLdap.unscoped.first
    old_pass = auth_source_ldap.account_password
    as_admin do
      put :update, {:commit => "Update", :id => auth_source_ldap.id, :auth_source_ldap => {:account_password => nil, :name => auth_source_ldap.name} }, set_session_user
    end
    auth_source_ldap = AuthSourceLdap.unscoped.find(auth_source_ldap.id)
    assert_equal old_pass, auth_source_ldap.account_password
  end

  test "LDAP test succeeded" do
    AuthSourceLdap.any_instance.stubs(:test_connection).returns(:success => true)
    put :test_connection, {:id => AuthSourceLdap.unscoped.first, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_response :success
  end

  test "LDAP test failed" do
    AuthSourceLdap.any_instance.stubs(:test_connection).raises(Foreman::Exception, 'Exception message')
    put :test_connection, {:id => AuthSourceLdap.unscoped.first, :auth_source_ldap => {:name => AuthSourceLdap.unscoped.first.name} }, set_session_user
    assert_response :unprocessable_entity
  end

  test 'organizations/locations can be assigned to it' do
    auth_source_ldap_params = { :name => AuthSourceLdap.unscoped.first.name,
                                :organization_ids => [taxonomies(:organization1).id],
                                :location_names => [taxonomies(:location1).name] }
    put :update, { :id => AuthSourceLdap.unscoped.first,
                   :auth_source_ldap => auth_source_ldap_params },
                   set_session_user
    assert_equal [taxonomies(:organization1)],
      AuthSourceLdap.unscoped.first.organizations.to_a
    assert_equal [taxonomies(:location1)],
      AuthSourceLdap.unscoped.first.locations.to_a
  end
end
