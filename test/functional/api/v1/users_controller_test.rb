require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase

  valid_attrs = { :login => "johnsmith" }

  test "should get index" do
    get :index, { }
    assert_response :success
  end

  test "should show individual record" do
    get :show, { :id => users(:one).to_param }
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
    user = users(:one)
    user.update_attribute :admin, true

    as_user :one do
      delete :destroy, { :id => user.id }
      assert_response :forbidden

      response = ActiveSupport::JSON.decode(@response.body)
      assert response['details'] == "You are trying to delete your own account"
      assert response['message'] == "Access denied"
      assert User.exists?(user)
    end
  end

  def user_one_as_anonymous_viewer
    users(:one).roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a user' do
    user_one_as_anonymous_viewer
    user = nil
    as_user :admin do
      user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
      user.save
    end
    as_user :one do
      put :update, { :id => user.id, :user => { :login => "johnsmith" } }
      assert_response :forbidden
    end
  end

  test 'user with viewer rights should succeed in viewing users' do
    user_one_as_anonymous_viewer
    as_user :one do
      get :index
      assert_response :success
    end
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
