require 'test_helper'

class Api::V2::UsersControllerTest < ActionController::TestCase
  def valid_attrs
    { :login => "johnsmith", :mail => 'john@example.com',
      :auth_source_id => auth_sources(:internal), :password => '123456' }
  end

  def setup
    setup_users
  end

  test "should get index" do
    get :index, { }
    assert_response :success
  end

  test "should handle taxonomy with wrong id" do
    get :index, { :location_id => taxonomies(:location1).id, :organization_id => 'missing' }
    assert_response :not_found
  end

  test "should show individual record by ID" do
    get :show, { :id => users(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not show_response.empty?
  end

  test "should show individual record by login name" do
    get :show, { :id => users(:one).login }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not show_response.empty?
  end

  test "shows default taxonomies on show response" do
    users(:one).update_attribute :locations, [taxonomies(:location1)]
    users(:one).update_attribute :default_location, taxonomies(:location1)
    get :show, { :id => users(:one).id }
    show_response = ActiveSupport::JSON.decode(@response.body)

    assert_equal taxonomies(:location1).id, show_response['default_location']['id']
    assert_equal nil, show_response['default_organization']
  end

  test "effective_admin is true if group admin is enabled" do
    user = users(:one)
    get :show, { :id => user.id }
    response = ActiveSupport::JSON.decode(@response.body)
    refute response["effective_admin"]

    FactoryGirl.create(:usergroup, :admin => true, :users => [user])
    get :show, { :id => user.id }
    response = ActiveSupport::JSON.decode(@response.body)
    assert response["effective_admin"]
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    put :update, { :id => user.id, :user => valid_attrs }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.login == "johnsmith"
  end

  test "should update admin flag" do
    user = users(:one)
    put :update, { :id => user.id, :user => { :admin => true } }

    assert_response :success
    assert User.unscoped.find_by_id(user.id).admin?
  end

  test "should not remove the default role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles =([roles(:default_role)])

    put :update, { :id => user.id, :user => { :login => "johnsmith" } }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)

    assert mod_user.roles =([roles(:default_role)])
  end

  test "should set password" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "dummy" } }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.matching_password?("dummy")
  end

  test "should detect password validation mismatches" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "DUMMY" } }
    assert_response :unprocessable_entity

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.matching_password?("changeme")
  end

  test "should delete different user" do
    user = users(:one)

    delete :destroy, { :id => user.id }
    assert_response :success

    refute User.unscoped.exists?(user.id)
  end

  test "should not delete same user" do
    user = users(:one)
    user.update_attribute :admin, true

    as_user :one do
      delete :destroy, { :id => user.id }
      assert_response :forbidden

      response = ActiveSupport::JSON.decode(@response.body)
      assert_equal "You are trying to delete your own account", response['error']['details']
      assert_equal "Access denied", response['error']['message']
      assert User.unscoped.exists?(user.id)
    end
  end

  def user_one_as_anonymous_viewer
    users(:one).roles = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a user' do
    user_one_as_anonymous_viewer
    user = nil
    as_admin do
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

  test 'admin user can be created' do
    user = users(:one)
    user.update_attribute :admin, true

    as_user :one do
      post :create, { :user => {
        :admin => true, :login => 'new_admin', :auth_source_id => auth_sources(:one).id }
      }
      assert_response :created
      assert User.find_by_login('new_admin').admin?
    end
  end

  test "#index should not show hidden users" do
    get :index, { :search => "login == #{users(:anonymous).login}" }
    results = ActiveSupport::JSON.decode(@response.body)
    assert results['results'].empty?, results.inspect
  end

  test "#find_resource should not return hidden users" do
    get :show, { :id => users(:anonymous).id }
    assert_response :not_found
  end

  test "#show should not allow displaying other users without proper permission" do
    as_user :two do
      get :show, { :id => users(:one).id }
    end
    assert_response :forbidden
  end

  test "#show should allow displaying myself without any special permissions" do
    as_user :two do
      get :show, { :id => users(:two).id }
    end
    assert_response :success
  end

  test "#update should not update other users without proper permission" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    as_user :two do
      put :update, { :id => user.id, :user => valid_attrs }
    end
    assert_response :forbidden
  end

  test "#update should allow updating myself without any special permissions with changing password" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one), :password => '123'
    as_user user do
      put :update, { :id => user.id, :user => valid_attrs.merge(:current_password => '123') }
    end
    assert_response :success
    user.reload
    assert user.matching_password?("123456")
  end

  test "#update should allow updating myself without any special permissions without changing password" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    as_user user do
      put :update, { :id => user.id, :user => valid_attrs.except(:password) }
    end
    assert_response :success
  end

  test '#update should not be editing User.current with changing password' do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one), :password => '123'

    as_user user do
      put :update, { :id => user.id, :user => valid_attrs.merge(:current_password => '123') }
    end
    assert_equal user, assigns(:user)
    refute_equal user.object_id, assigns(:user).object_id
    assert_response :success
    user.reload
    assert user.matching_password?('123456')
  end

  test '#update should not be editing User.current without changing password' do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    as_user user do
      put :update, { :id => user.id, :user => valid_attrs.except(:password) }
    end
    assert_equal user, assigns(:user)
    refute_equal user.object_id, assigns(:user).object_id
    assert_response :success
  end
end
