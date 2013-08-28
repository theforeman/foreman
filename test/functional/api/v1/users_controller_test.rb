require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase

  valid_attrs = { :login => "johnsmith" }

  def setup
    User.current = users(:admin)
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).login, "secret")
  end

  test "should get index" do
    get :index, { }
    assert_response :success
  end

  test "should show individual record" do
    get :show, { :id => users(:internal).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    put :update, { :id => user.id, :user => valid_attrs }
    assert_response :success

    mod_user = User.find_by_id(user.id)
    assert mod_user.login == "johnsmith"
  end

  test "should not remove the anonymous role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles =([roles(:anonymous)])

    put :update, { :id => user.id, :user => { :login => "johnsmith" } }
    assert_response :success

    mod_user = User.find_by_id(user.id)

    assert mod_user.roles =([roles(:anonymous)])
  end

  test "should set password" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "dummy" } }
    assert_response :success

    mod_user = User.find_by_id(user.id)
    assert mod_user.matching_password?("dummy")

  end

  test "should detect password validation mismatches" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "DUMMY" } }
    assert_response :unprocessable_entity

    mod_user = User.find_by_id(user.id)
    assert mod_user.matching_password?("changeme")
  end

  test "should delete different user" do
    user = users(:one)

    delete :destroy, { :id => user.id }
    assert_response :success

    assert !User.exists?(user.id)
  end

  test "should not delete same user" do
    user = users(:internal)
    user.update_attribute :admin, true
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, "secret")

    delete :destroy, { :id => user.id }
    assert_response :forbidden

    response = ActiveSupport::JSON.decode(@response.body)
    assert response['details'] == "You are trying to delete your own account"
    assert response['message'] == "Access denied"
    assert User.exists?(user)
  end

  test 'user with viewer rights should fail to edit a user' do
    user = User.create! :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    users(:internal).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:internal).login, "secret")

    put :update, { :id => user.id, :user => { :login => "johnsmith" } }
    assert_response :forbidden
  end

  test 'user with viewer rights should succeed in viewing users' do
    users(:internal).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(users(:internal).login, "secret")

    get :index
    assert_response :success
  end

  test 'admin user can be created' do
    user = users(:internal)
    user.update_attribute :admin, true
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user.login, "secret")

    post :create, { :user => {
        :admin => true, :login => 'new_admin', :auth_source_id => auth_sources(:one).id }
    }
    assert_response :success
    assert User.find_by_login('new_admin').admin?
  end

# do we support this?
=begin
  test "should recreate the admin account" do
    user = users(:one)
    user.update_attribute :admin, true

    User.find_by_login("admin").delete # Of course we only use destroy in the codebase
    assert User.find_by_login("admin").nil?

    as_user :one do
      get :index, {}
      assert_response :success
    end

    assert !User.find_by_login("admin").nil?
  end
=end

end
