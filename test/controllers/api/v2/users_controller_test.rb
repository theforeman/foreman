require 'test_helper'

class Api::V2::UsersControllerTest < ActionController::TestCase
  def valid_attrs
    { :mail => 'john@example.com',
      :auth_source_id => auth_sources(:internal), :password => '123456' }
  end

  def min_valid_attrs
    { :login => "foo", :auth_source_id => auth_sources(:internal).id, :password => '123456' }
  end

  # List of invalid emails.
  def invalid_usernames_list
    [
      '',
      "space #{RFauxFactory.gen_alpha}",
      RFauxFactory.gen_alpha(101),
      RFauxFactory.gen_html,
    ]
  end

  def setup
    setup_users
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should handle taxonomy with wrong id" do
    get :index, params: { :location_id => taxonomies(:location1).id, :organization_id => 'missing' }
    assert_response :not_found
  end

  test "should show individual record by ID" do
    get :show, params: { :id => users(:one).id }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not show_response.empty?
  end

  test "should show individual record by login name" do
    get :show, params: { :id => users(:one).login }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_not show_response.empty?
  end

  test "should show current user" do
    as_user(:one) do
      get :show_current
      assert_response :success
      show_response = ActiveSupport::JSON.decode(@response.body)
      assert_equal show_response['id'], users(:one).id
    end
  end

  test "should not show current user when not logged in" do
    User.current = nil
    @request.session[:user] = nil
    reset_api_credentials
    get :show_current
    assert_response :unauthorized
  end

  test "shows default taxonomies on show response" do
    users(:one).update_attribute :locations, [taxonomies(:location1)]
    users(:one).update_attribute :default_location, taxonomies(:location1)
    get :show, params: { :id => users(:one).id }
    show_response = ActiveSupport::JSON.decode(@response.body)

    assert_equal taxonomies(:location1).id, show_response['default_location']['id']
    assert_nil show_response['default_organization']
  end

  test "effective_admin is true if group admin is enabled" do
    user = users(:one)
    get :show, params: { :id => user.id }
    response = ActiveSupport::JSON.decode(@response.body)
    refute response["effective_admin"]

    as_admin { FactoryBot.create(:usergroup, :admin => true, :users => [user]) }
    get :show, params: { :id => user.id }
    response = ActiveSupport::JSON.decode(@response.body)
    assert response["effective_admin"]
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    put :update, params: { :id => user.id, :user => valid_attrs }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.mail == "john@example.com"
  end

  test "should update admin flag" do
    user = users(:one)
    put :update, params: { :id => user.id, :user => { :admin => true } }

    assert_response :success
    assert User.unscoped.find_by_id(user.id).admin?
  end

  test "should not remove the default role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles = [roles(:default_role)]

    put :update, params: { :id => user.id, :user => { :mail => "bar@foo.com" } }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)

    assert mod_user.roles = [roles(:default_role)]
  end

  test "should set password" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, params: { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "dummy" } }
    assert_response :success

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.matching_password?("dummy")
  end

  test "should detect password validation mismatches" do
    user          = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, params: { :id => user.id, :user => { :login => "johnsmith", :password => "dummy", :password_confirmation => "DUMMY" } }
    assert_response :unprocessable_entity

    mod_user = User.unscoped.find_by_id(user.id)
    assert mod_user.matching_password?("changeme")
  end

  test "should delete different user" do
    user = users(:one)

    delete :destroy, params: { :id => user.id }
    assert_response :success

    refute User.unscoped.exists?(user.id)
  end

  test "should not delete same user" do
    user = users(:one)
    user.update_attribute :admin, true

    as_user :one do
      delete :destroy, params: { :id => user.id }
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
      put :update, params: { :id => user.id, :user => { :login => "johnsmith" } }
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
      post :create, params: { :user => {
        :admin => true, :login => 'new_admin', :auth_source_id => auth_sources(:one).id },
      }
      assert_response :created
      assert User.unscoped.find_by_login('new_admin').admin?
    end
  end

  test "#index should not show hidden users" do
    get :index, params: { :search => "login == #{users(:anonymous).login}" }
    results = ActiveSupport::JSON.decode(@response.body)
    assert results['results'].empty?, results.inspect
  end

  test "#find_resource should not return hidden users" do
    get :show, params: { :id => users(:anonymous).id }
    assert_response :not_found
  end

  test "#show should not allow displaying other users without proper permission" do
    as_user :two do
      get :show, params: { :id => users(:one).id }
    end
    assert_response :forbidden
  end

  test "#show should allow displaying myself without any special permissions" do
    as_user :two do
      get :show, params: { :id => users(:two).id }
    end
    assert_response :success
  end

  test "#update should not update other users without proper permission" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    as_user :two do
      put :update, params: { :id => user.id, :user => valid_attrs }
    end
    assert_response :forbidden
  end

  test "#update should allow updating myself without any special permissions with changing password" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one), :password => '123'
    as_user user do
      put :update, params: { :id => user.id, :user => valid_attrs.merge(:current_password => '123') }
    end
    assert_response :success
    user.reload
    assert user.matching_password?("123456")
  end

  test "#update should allow updating myself without any special permissions without changing password" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    as_user user do
      put :update, params: { :id => user.id, :user => valid_attrs.except(:password) }
    end
    assert_response :success
  end

  test '#update should not be editing User.current with changing password' do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one), :password => '123'

    as_user user do
      put :update, params: { :id => user.id, :user => valid_attrs.merge(:current_password => '123') }
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
      put :update, params: { :id => user.id, :user => valid_attrs.except(:password) }
    end
    assert_equal user, assigns(:user)
    refute_equal user.object_id, assigns(:user).object_id
    assert_response :success
  end

  test "should not create with invalid email" do
    mail = 'foreman@'
    post :create, params: { :user => min_valid_attrs.clone.update(:mail => mail) }
    assert_response :unprocessable_entity, "Can create user with invalid mail #{mail}"
  end

  test "should not create with invalid firstname" do
    firstname = RFauxFactory.gen_alpha(51)
    post :create, params: { :user => min_valid_attrs.clone.update(:firstname => firstname) }
    assert_response :unprocessable_entity, "Can create user with invalid firstname #{firstname}"
  end

  test "should not create with invalid lastname" do
    lastname = RFauxFactory.gen_alpha(51)
    post :create, params: { :user => min_valid_attrs.clone.update(:lastname => lastname) }
    assert_response :unprocessable_entity, "Can create user with invalid lastname #{lastname}"
  end

  test "should not create with invalid username" do
    login = ""
    post :create, params: { :user => min_valid_attrs.clone.update(:login => login) }
    assert_response :unprocessable_entity, "Can create user with invalid login #{login}"
  end

  test "should create with valid description" do
    description = RFauxFactory.gen_alpha
    post :create, params: { :user => min_valid_attrs.clone.update(:description => description) }
    assert_response :success, "creation with description #{description} failed with code #{response.code}"
    assert_equal JSON.parse(@response.body)['description'], description, "Can't create user with valid description #{description}"
  end

  test "should create with valid email" do
    mail = "#{RFauxFactory.gen_alpha}@example.com"
    post :create, params: { :user => min_valid_attrs.clone.update(:mail => mail) }
    assert_response :success, "creation with mail #{mail} failed with code #{response.code}"
    assert_equal JSON.parse(@response.body)['mail'], mail, "Can't create user with valid mail #{mail}"
  end

  test "should create with valid firstname" do
    firstname = RFauxFactory.gen_alpha
    post :create, params: { :user => min_valid_attrs.clone.update(:firstname => firstname) }
    assert_response :success, "creation with firstname #{firstname} failed with code #{response.code}"
    assert_equal JSON.parse(@response.body)['firstname'], firstname, "Can't create user with valid firstname #{firstname}"
  end

  test "should create with valid lastname" do
    lastname = RFauxFactory.gen_alpha
    post :create, params: { :user => min_valid_attrs.clone.update(:lastname => lastname) }
    assert_response :success, "creation with lastname #{lastname} failed with code #{response.code}"
    assert_equal JSON.parse(@response.body)['lastname'], lastname, "Can't create user with valid lastname #{lastname}"
  end

  test "should create with valid password" do
    password = RFauxFactory.gen_alpha
    post :create, params: { :user => min_valid_attrs.clone.update(:password => password) }
    assert_response :success, "creation with password #{password} failed with code #{response.code}"
  end

  test "should create with valid username" do
    login = RFauxFactory.gen_alpha
    post :create, params: { :user => min_valid_attrs.clone.update(:login => login) }
    assert_response :success, "creation with login #{login} failed with code #{response.code}"
    assert_equal JSON.parse(@response.body)['login'], login, "Can't create user with valid login #{login}"
  end

  test "should update with valid username" do
    login = RFauxFactory.gen_alpha
    put :update, params: { :id => users(:apiadmin).id, :user => {:login => login } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['login'], login, "Can't update user with valid login #{login}"
  end

  test "should update with admin attribute true" do
    admin = true
    put :update, params: { :id => users(:one).id, :user => {:admin => admin } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['admin'], admin, "Can't update user with valid admin attribute #{admin}"
  end

  test "should update with admin attribute false" do
    admin = false
    put :update, params: { :id => users(:apiadmin).id, :user => {:admin => admin } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['admin'], admin, "Can't update user with valid admin attribute #{admin}"
  end

  test "should update with valid description" do
    description = RFauxFactory.gen_alpha
    put :update, params: { :id => users(:one).id, :user => {:description => description } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['description'], description, "Can't update user with valid description #{description}"
  end

  test "should update with valid mail" do
    mail = "#{RFauxFactory.gen_alpha}@example.com"
    put :update, params: { :id => users(:one).id, :user => {:mail => mail } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['mail'], mail, "Can't update user with valid mail #{mail}"
  end

  test "should update with valid firstname" do
    firstname = RFauxFactory.gen_alpha
    put :update, params: { :id => users(:one).id, :user => {:firstname => firstname } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['firstname'], firstname, "Can't update user with valid firstname #{firstname}"
  end

  test "should update with valid lastname" do
    lastname = RFauxFactory.gen_alpha
    put :update, params: { :id => users(:one).id, :user => {:lastname => lastname } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['lastname'], lastname, "Can't update user with valid lastname #{lastname}"
  end

  test "should create with roles" do
    roles = [Role.find_by_name('Manager'), Role.find_by_name('View hosts')]
    post :create, params: { :user => min_valid_attrs.clone.update(:role_ids => roles.map { |role| role.id }) }
    assert_response :success
    assert_equal JSON.parse(@response.body)['roles'].map { |role| role["id"] }, roles.map { |role| role.id }, "Can't create user with valid roles #{roles}"
  end

  test "should update with roles" do
    roles = [Role.find_by_name('Manager'), Role.find_by_name('View hosts')]
    put :update, params: { :id => users(:two).id, :user => {:role_ids => roles.map { |role| role.id } } }
    assert_response :success
    assert_equal JSON.parse(@response.body)['roles'].map { |role| role["id"] }, roles.map { |role| role.id }, "Can't update user with valid roles #{roles}"
  end

  test "should create user with escalated roles as system admin" do
    roles = [Role.find_by_name('Manager')]
    org = FactoryBot.create(:organization)
    loc = FactoryBot.create(:location)
    system_admin = FactoryBot.create :user, :login => 'ca',
                                     :role_ids => [roles(:system_admin).id],
                                     :organization_ids => [org.id],
                                     :location_ids => [loc.id]
    as_user system_admin do
      post :create, params: { :user => min_valid_attrs.clone.update(:role_ids => roles.map { |role| role.id },
                                                                    :organization_ids => [org.id],
                                                                    :location_ids => [loc.id]) }
      assert_response :success
    end
  end

  test "should disable another user" do
    as_admin do
      put :update, params: { :id => users(:one).id, :disabled => true }
    end
    assert_response :success
    assert_equal JSON.parse(@response.body)['disabled'], true, 'User is not disabled'
  end

  test "user can't disable himself" do
    as_user :two do
      put :update, params: { :id => users(:two).id, :disabled => true }
    end
    assert_response :unprocessable_entity
  end

  test "invalidate_jwts - user with tokens" do
    user = FactoryBot.create(:user, admin: true)
    user.jwt_token! # Generate JWT (& secret)

    as_user(user) { delete :invalidate_jwts, params: { id: user.id } }

    assert_response :success
    assert_equal JSON.parse(@response.body)['success_msg'], 'JSON web tokens successfully invalidated'
  end

  test "invalidate_jwts - user without tokens" do
    user = FactoryBot.create(:user, admin: true)

    as_user(user) { delete :invalidate_jwts, params: { id: user.id } }

    assert_response :success
    assert_equal JSON.parse(@response.body)['success_msg'], 'JSON web tokens successfully invalidated'
  end
end
