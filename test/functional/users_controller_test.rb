require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    setup_users
    Setting::Auth.load_defaults
  end

  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
  end

  test "#index should not show hidden users" do
    get :index, { :search => "login = #{users(:anonymous).login}" }, set_session_user
    assert_response :success
    assert_empty assigns(:users)
  end

  test "should get edit" do
    u = User.new :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    assert u.save!
    logger.info "************ ID = #{u.id}"
    get :edit, {:id => u.id}, set_session_user
    assert_response :success
  end

  test "#edit should not find a hidden user" do
    get :edit, {:id => users(:anonymous).id}, set_session_user
    assert_response :not_found
  end

  test 'should create regular user' do
    post :create, {
      :user => {
        :login          => 'foo',
        :mail           => 'foo@bar.com',
        :auth_source_id => auth_sources(:internal).id,
        :password       => 'changeme'
      }
    }, set_session_user
    assert_redirected_to users_path
    refute User.find_by_login('foo').admin
  end

  test 'should create admin user' do
    post :create, {
      :user => {
        :login          => 'foo',
        :admin          => true,
        :mail           => 'foo@bar.com',
        :auth_source_id => auth_sources(:internal).id,
        :password       => 'changeme'
      }
    }, set_session_user
    assert_redirected_to users_path
    assert User.find_by_login('foo').admin
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    put :update, { :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.login == "johnsmith"
    assert_redirected_to users_path
  end

  test "should assign a mail notification" do
    user = FactoryGirl.create(:user, :with_mail)
    notification = FactoryGirl.create(:mail_notification)
    put :update, { :id => user.id, :user => { :mail_notification_ids => [notification.id] }}, set_session_user
    user = User.find_by_id(user.id)
    assert user.mail_notifications.include? notification
  end

  test "user changes should expire topbar cache" do
    user = FactoryGirl.create(:user, :with_mail)
    User.any_instance.expects(:expire_topbar_cache).once
    put :update, { :id => user.id, :user => {:admin => true, :mail => user.mail} }, set_session_user
  end

  test "role changes should expire topbar cache" do
    user = FactoryGirl.create(:user, :with_mail)
    role1 = FactoryGirl.create :role
    UserRole.any_instance.expects(:expire_topbar_cache).at_least(1)
    put :update, { :id => user.id, :user => {:role_ids => [role1.id]} }, set_session_user
  end

  test "should not remove the anonymous role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles =([roles(:anonymous)])

    put :update, { :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.roles =([roles(:anonymous)])
  end

  test "should set password" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, {:id => user.id,
                  :user => {
                    :login => "johnsmith", :password => "dummy", :password_confirmation => "dummy"
                  },
                 }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.matching_password?("dummy")
    assert_redirected_to users_path
  end

  test "should detect password validation mismatches" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, {:id => user.id,
                  :user => {
                    :login => "johnsmith", :password => "dummy", :password_confirmation => "DUMMY"
                  },
                 }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.matching_password?("changeme")
    assert_template :edit
  end

  test "should not ask for confirmation if no password is set" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, {:id => user.id,
                  :user => { :login => "foobar" },
                 }, set_session_user

    assert_redirected_to users_url
  end

  test "should delete different user" do
    user = users(:one)
    delete :destroy, {:id => user}, set_session_user.merge(:user => users(:admin))
    assert_redirected_to users_url
    assert !User.exists?(user.id)
  end

  test "should modify session when locale is updated" do
    as_admin do
      put :update, { :id => users(:admin).id, :user => { :locale => "cs" } }, set_session_user
      assert_redirected_to users_url
      assert_equal "cs", users(:admin).reload.locale

      put :update, { :id => users(:admin).id, :user => { :locale => "" } }, set_session_user
      assert_nil users(:admin).reload.locale
      assert_nil session[:locale]
    end
  end

  test "should not delete same user" do
    return unless SETTINGS[:login]
    @request.env['HTTP_REFERER'] = users_path
    user = users(:one)
    user.update_attribute :admin, true
    delete :destroy, {:id => user.id}, set_session_user.merge(:user => user.id)
    assert_redirected_to users_url
    assert User.exists?(user)
    assert @request.flash[:notice] == "You cannot delete this user while logged in as this user."
  end

  test 'user with viewer rights should fail to edit a user' do
    get :edit, {:id => users(:admin).id}
    assert_response 404
  end

  test 'user with viewer rights should succeed in viewing users' do
    get :index
    assert_response :success
  end

  test "should clear the current user after processing the request" do
    get :index, {}, set_session_user
    assert User.current.nil?
  end

  test "should be able to create user without mail and update the mail later" do
    user = User.create :login => "mailess", :mail=> nil, :auth_source => auth_sources(:one)
    user.admin = true
    user.save!(:validate => false)

    update_hash = {"user"=>{
      "login"  => user.login,
      "mail"  => "you@have.mail"},
      "id"     => user.id}
    put :update, update_hash, set_session_user.merge(:user => user.id)

    assert !User.find_by_login(user.login).mail.blank?
  end

  test "should login external user" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    @request.env['REMOTE_USER'] = users(:admin).login
    get :extlogin, {}, {}
    assert_redirected_to hosts_path
  end

  test "should logout external user" do
    @sso = mock('dummy_sso')
    @sso.stubs(:authenticated?).returns(true)
    @sso.stubs(:logout_url).returns("/users/extlogout")
    @sso.stubs(:current_user).returns(users(:admin).login)
    @controller.stubs(:available_sso).returns(@sso)
    @controller.stubs(:get_sso_method).returns(@sso)
    get :extlogin, {}, {}
    get :logout, {}, {}
    assert_redirected_to '/users/extlogout'
  end

  test "should login external user preserving uri" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    @request.env['REMOTE_USER'] = users(:admin).login
    get :extlogin, {}, {:original_uri => '/test'}
    assert_redirected_to '/test'
  end

  test "should create and login external user" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache_mod'
    @request.session = nil
    @request.env['REMOTE_USER'] = 'ares'
    get :extlogin, {}, {}
    assert_redirected_to edit_user_path(User.find_by_login('ares'))
  end

  test "should use intercept if available" do
    SSO::FormIntercept.any_instance.stubs(:available?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:authenticated?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:current_user).returns(users(:admin))
    post :login, {:login => {:login => 'ares', :password => 'password_that_does_not_match'} }
    assert_redirected_to hosts_path
  end

  test 'non admin user should edit itself' do
    User.current = users(:one)
    get :edit, { :id => User.current.id }
    assert_response :success
  end

  test 'non admin user should be able to update itself' do
    User.current = users(:one)
    put :update, { :id => users(:one).id, :user => { :firstname => 'test' } }
    assert_response :redirect
  end

  test 'user without edit permission should not be able to edit another user' do
    User.current = users(:one)
    get :edit, { :id => users(:two) }
    assert_response :not_found
  end

  test 'user with edit permission should be able to edit another user' do
    setup_user 'edit', 'users'
    get :edit, { :id => users(:two) }
    assert_response :success
  end

  test 'user without edit permission should not be able to update another user' do
    User.current = users(:one)
    put :update, { :id => users(:two).id, :user => { :firstname => 'test' } }
    assert_response :forbidden
  end

  test 'user with update permission should be able to update another user' do
    setup_user 'edit', 'users'
    put :update, { :id => users(:two).id, :user => { :firstname => 'test' } }

    assert_response :redirect
  end

  test "#login sets the session user" do
    post :login, {:login => {'login' => users(:admin).login, 'password' => 'secret'}}
    assert_redirected_to hosts_path
    assert_equal users(:admin).id, session[:user]
  end

  test "#login resets the session ID to prevent fixation" do
    @controller.expects(:reset_session)
    post :login, {:login => {'login' => users(:admin).login, 'password' => 'secret'}}
  end

  test "#login doesn't escalate privileges in the old session" do
    old_session = session
    post :login, {:login => {'login' => users(:admin).login, 'password' => 'secret'}}
    refute old_session.keys.include?(:user), "old session contains user"
    assert session[:user], "new session doesn't contain user"
  end

  test "#login refuses logins when User.try_to_login fails" do
    u = FactoryGirl.create(:user)
    User.expects(:try_to_login).with(u.login, 'password').returns(nil)
    post :login, {:login => {'login' => u.login, 'password' => 'password'}}
    assert_redirected_to login_users_path
    assert flash[:error].present?
  end

  test "#login retains taxonomy session attributes in new session" do
    post :login, {:login => {'login' => users(:admin).login, 'password' => 'secret'}},
                 {:location_id => taxonomies(:location1).id,
                  :organization_id => taxonomies(:organization1).id,
                  :foo => 'bar'}
    assert_equal taxonomies(:location1).id, session[:location_id]
    assert_equal taxonomies(:organization1).id, session[:organization_id]
    refute session[:foo], "session contains 'foo', but should have been reset"
  end

  test "#login renders login page" do
    get :login
    assert_response :success
  end

  test "#login renders login page with 401 status from parameter" do
    get :login, :status => '401'
    assert_response 401
  end

  context 'default taxonomies' do
    test 'logging in loads default taxonomies' do
      users(:one).update_attributes(:default_location_id     => taxonomies(:location1).id,
                                    :default_organization_id => taxonomies(:organization1).id,
                                    :password                => 'changeme')

      User.expects(:try_to_login).with(users(:one).login, users(:one).password).
        returns(users(:one).post_successful_login)

      post :login, { :login => { :login => users(:one).login, :password => users(:one).password } }
      assert_equal session['organization_id'], users(:one).default_organization_id
      assert_equal session['location_id'],     users(:one).default_location_id
    end

    test 'users can update their own default taxonomies' do
      users(:one).update_attributes(:locations     => [taxonomies(:location1)],
                                    :organizations => [taxonomies(:organization1)])

      put :update, { :id   => users(:one).id,
                     :user => { :default_location_id     => taxonomies(:location1).id,
                                :default_organization_id => taxonomies(:organization1).id } }
      assert_redirected_to users_path

      updated_user = User.find(users(:one).id)
      assert_equal taxonomies(:location1),     updated_user.default_location
      assert_equal taxonomies(:organization1), updated_user.default_organization
    end
  end

  context "CSRF" do
    setup do
      ActionController::Base.allow_forgery_protection = true
    end

    teardown do
      ActionController::Base.allow_forgery_protection = false
    end

    test "throws exception when CSRF token is invalid or not present" do
      assert_raises Foreman::Exception do
        post :logout, {}, set_session_user
      end
    end

    test "allows logout when CSRF token is correct" do
      @controller.expects(:verify_authenticity_token).returns(true)
      post :logout, {}, set_session_user
      assert_response :found
      assert_redirected_to "/users/login"
    end
  end
end
