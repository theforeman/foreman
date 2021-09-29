require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    setup_users
    @model = User.last
  end

  basic_index_test('users')
  basic_new_test
  basic_edit_test('user')
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "#index should not show hidden users" do
    get :index, params: { :search => "login = #{users(:anonymous).login}" }, session: set_session_user
    assert_response :success
    assert_empty assigns(:users)
  end

  test "#edit should not find a hidden user" do
    get :edit, params: { :id => users(:anonymous).id }, session: set_session_user
    assert_response :not_found
  end

  test 'should create regular user' do
    post :create, params: {
      :user => {
        :login          => 'foo',
        :mail           => 'foo@bar.com',
        :auth_source_id => auth_sources(:internal).id,
        :password       => 'changeme',
      },
    }, session: set_session_user
    assert_redirected_to users_path
    refute User.unscoped.find_by_login('foo').admin
  end

  test 'should create admin user' do
    post :create, params: {
      :user => {
        :login          => 'foo',
        :admin          => true,
        :mail           => 'foo@bar.com',
        :auth_source_id => auth_sources(:internal).id,
        :password       => 'changeme',
      },
    }, session: set_session_user
    assert_redirected_to users_path
    assert User.unscoped.find_by_login('foo').admin
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    put :update, params: { :id => user.id, :user => {:mail => "bar@foo.com"} }, session: set_session_user
    mod_user = User.unscoped.find_by_id(user.id)

    assert mod_user.mail == "bar@foo.com"
    assert_redirected_to users_path
  end

  test "should assign a mail notification" do
    user = FactoryBot.create(:user, :with_mail)
    notification = FactoryBot.create(:mail_notification)
    put :update, params: { :id => user.id, :user => {:user_mail_notifications_attributes => {'0' => {:mail_notification_id => notification.id, :interval => 'Subscribe'}}} }, session: set_session_user
    user = User.unscoped.find_by_id(user.id)
    assert user.mail_notifications.include? notification
  end

  test "user changes should expire topbar cache" do
    user = FactoryBot.create(:user, :with_mail)
    User.any_instance.expects(:expire_topbar_cache).once
    put :update, params: { :id => user.id, :user => {:admin => true, :mail => user.mail} }, session: set_session_user
  end

  test "role changes should expire topbar cache" do
    user = FactoryBot.create(:user, :with_mail)
    role1 = FactoryBot.create :role
    UserRole.any_instance.expects(:expire_topbar_cache).at_least(1)
    put :update, params: { :id => user.id, :user => {:role_ids => [role1.id]} }, session: set_session_user
  end

  test "should not remove the default role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles = [roles(:default_role)]

    put :update, params: { :id => user.id, :user => {:login => "johnsmith"} }, session: set_session_user
    mod_user = User.unscoped.find_by_id(user.id)

    assert mod_user.roles = [roles(:default_role)]
  end

  test "should set password" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, params: { :id => user.id,
                           :user => {
                             :login => "johnsmith", :password => "dummy", :password_confirmation => "dummy"
                           },
                 }, session: set_session_user

    mod_user = User.unscoped.find_by_id(user.id)

    assert mod_user.matching_password?("dummy")
    assert_redirected_to users_path
  end

  test "should detect password validation mismatches" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, params: { :id => user.id,
                  :user => {
                    :login => "johnsmith", :password => "dummy", :password_confirmation => "DUMMY"
                  },
                }, session: set_session_user
    user.reload
    assert user.matching_password?("changeme")
    assert_template :edit
  end

  test "should not ask for confirmation if no password is set" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, params: { :id => user.id,
                           :user => { :login => "foobar" },
                         }, session: set_session_user

    assert_redirected_to users_url
  end

  test "current user have to enter current password to change password" do
    user = FactoryBot.create(:user, :password => 'password')
    User.current = user

    put :update, params: { :id => user.id,
                           :user => {
                             :current_password => "password", :password => "newpassword", :password_confirmation => "newpassword"
                           },
    }, session: set_session_user

    user.reload
    assert user.matching_password?("newpassword")
    assert_redirected_to users_path
  end

  test "should delete different user" do
    user = users(:one)
    delete :destroy, params: { :id => user }, session: set_session_user.merge(:user => users(:admin).id)
    assert_redirected_to users_url
    assert !User.exists?(user.id)
  end

  test "should modify session when locale is updated" do
    as_admin do
      put :update, params: { :id => users(:admin).id, :user => { :locale => "cs" } }, session: set_session_user
      assert_redirected_to users_url
      assert_equal "cs", users(:admin).reload.locale

      put :update, params: { :id => users(:admin).id, :user => { :locale => "" } }, session: set_session_user
      assert_nil users(:admin).reload.locale
      assert_nil session[:locale]
    end
  end

  test "should not delete same user" do
    @request.env['HTTP_REFERER'] = users_path
    user = users(:one)
    user.update_attribute :admin, true
    delete :destroy, params: { :id => user.id }, session: set_session_user.merge(:user => user.id)
    assert_redirected_to users_url
    assert User.unscoped.exists?(user.id)
    assert_equal @request.flash[:warning][:message], 'You cannot delete this user while logged in as this user'
    assert_equal @request.flash[:warning][:link], { text: _("Logout"), href: logout_users_url }
  end

  test 'user with viewer rights should fail to edit a user' do
    get :edit, params: { :id => users(:admin).id }
    assert_response 404
  end

  test 'user with viewer rights should succeed in viewing users' do
    get :index
    assert_response :success
  end

  test "should clear the current user after processing the request" do
    get :index, session: set_session_user
    assert User.current.nil?
  end

  test "should be able to create user without mail and update the mail later" do
    user = User.create :login => "mailess", :mail => nil, :auth_source => auth_sources(:one)
    user.admin = true
    user.save!(:validate => false)

    update_hash = {"user" => {
      "login" => user.login,
      "mail" => "you@have.mail"},
      "id" => user.id}
    put :update, params: update_hash, session: set_session_user.merge(:user => user.id)

    assert User.unscoped.find_by_login(user.login).mail.present?
  end

  test 'should redirect disabled user to login page' do
    users(:one).update(disabled: true)
    get :index, session: set_session_user(:one)
    assert_redirected_to '/users/login'
  end

  test "should login external user" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    time = Time.zone.now
    @request.env['HTTP_REMOTE_USER'] = users(:admin).login
    get :extlogin, session: {:user => users(:admin).id }
    assert_redirected_to hosts_path
    users(:admin).reload
    assert users(:admin).last_login_on.to_i >= time.to_i, 'User last login time was not updated'
  end

  test "should logout external user" do
    @sso = mock('dummy_sso')
    @sso.stubs(:authenticated?).returns(true)
    @sso.stubs(:logout_url).returns("/users/extlogout")
    @sso.stubs(:current_user).returns(users(:admin).login)
    @controller.stubs(:available_sso).returns(@sso)
    @controller.stubs(:get_sso_method).returns(@sso)
    get :extlogin
    post :logout
    assert_redirected_to '/users/extlogout'
  end

  test "should redirect disabled external user to login page" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    users(:external).update(disabled: true)
    @request.env['HTTP_REMOTE_USER'] = users(:external).login
    get :extlogin, session: {:user => users(:external).id }
    assert_redirected_to '/users/login'
  end

  test "should login external user preserving uri" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    @request.env['HTTP_REMOTE_USER'] = users(:admin).login
    get :extlogin, session: { :original_uri => '/test' }
    assert_redirected_to '/test'
  end

  test "should create and login external user" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache_mod'
    @request.session.clear
    @request.env['HTTP_REMOTE_USER'] = 'ares'
    get :extlogin
    assert_redirected_to edit_user_path(User.unscoped.find_by_login('ares'))
  end

  test "should use intercept if available" do
    SSO::FormIntercept.any_instance.stubs(:available?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:authenticated?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:current_user).returns(users(:admin))
    post :login, params: { :login => {:login => 'ares', :password => 'password_that_does_not_match'} }
    assert_redirected_to hosts_path
  end

  test 'non admin user should edit itself' do
    User.current = users(:one)
    get :edit, params: { :id => User.current.id }
    assert_response :success
  end

  test 'user should not be editing User.current' do
    user = users(:one)
    User.expects(:current).at_least_once.returns(user)
    get :edit, params: { :id => user.id }
    assert_equal user, assigns(:user)
    refute_equal user.object_id, assigns(:user).object_id
    assert_response :success
  end

  test 'non admin user should be able to update itself' do
    User.current = users(:one)
    put :update, params: { :id => users(:one).id, :user => { :firstname => 'test' } }
    assert_response :redirect
  end

  test 'user without edit permission should not be able to edit another user' do
    User.current = users(:one)
    get :edit, params: { :id => users(:two) }
    assert_response :not_found
  end

  test 'user with edit permission should be able to edit another user' do
    setup_user 'edit', 'users'
    get :edit, params: { :id => users(:two) }, session: set_session_user
    assert_response :success
  end

  test 'user without edit permission should not be able to update another user' do
    User.current = users(:one)
    put :update, params: { :id => users(:two).id, :user => { :firstname => 'test' } }
    assert_response :forbidden
  end

  test 'user with update permission should be able to update another user' do
    setup_user 'edit', 'users'
    put :update, params: { :id => users(:two).id, :user => { :firstname => 'test' } },
      session: set_session_user

    assert_response :redirect
  end

  test 'user with no permission should be able to update himself or herself' do
    user = FactoryBot.create(:user, :mail => nil)
    setup_user 'view', 'hosts', nil, user
    put :update, params: { :id => user.id, :user => { :mail => 'test@example.com' } },
      session: set_session_user(user)

    assert_response :redirect
    assert_redirected_to hosts_path
  end

  test "#login sets the session user and bumps last log in time" do
    time = Time.zone.now
    post :login, params: { :login => {'login' => users(:admin).login, 'password' => 'secret'} }
    assert_redirected_to hosts_path
    assert_equal users(:admin).id, session[:user]
    users(:admin).reload
    assert users(:admin).last_login_on.to_i >= time.to_i, 'User last login on was not updated'
  end

  test "#login resets the session ID to prevent fixation" do
    @controller.expects(:reset_session)
    post :login, params: { :login => {'login' => users(:admin).login, 'password' => 'secret'} }
  end

  test "#login refuses logins when User.try_to_login fails" do
    u = FactoryBot.create(:user)
    User.expects(:try_to_login).with(u.login, 'password').returns(nil)
    post :login, params: { :login => {'login' => u.login, 'password' => 'password'} }
    assert_redirected_to login_users_path
    assert flash[:inline][:error].present?
  end

  test "#login prevents brute-force login attempts" do
    User.expects(:try_to_login).times(30).returns(nil)
    @controller.expects(:log_bruteforce)
    31.times do
      post :login, params: { :login => {'login' => 'admin', 'password' => 'password'} }
    end
    assert_equal "Too many tries, please try again in a few minutes.", flash[:inline][:error]
  end

  test "#login retains taxonomy session attributes in new session" do
    post :login, params: { :login => {'login' => users(:admin).login, 'password' => 'secret'}},
         session: { :location_id => taxonomies(:location1).id,
                    :organization_id => taxonomies(:organization1).id,
                    :foo => 'bar' }
    assert_equal taxonomies(:location1).id, session[:location_id]
    assert_equal taxonomies(:organization1).id, session[:organization_id]
    refute session[:foo], "session contains 'foo', but should have been reset"
  end

  test "#login renders login page" do
    session.clear
    get :login
    assert_response :success
  end

  test "#login renders login page with 401 status from parameter" do
    get :login, params: { :status => '401' }
    assert_response 401
  end

  test "#login shows a warning for any user model errors" do
    attrs = {:firstname => "foo", :mail => "foo#bar", :login => "ldap-user", :auth_source_id => auth_sources(:one).id}
    AuthSourceLdap.any_instance.stubs(:authenticate).returns(attrs)
    AuthSourceLdap.any_instance.stubs(:update_usergroups).returns(true)
    AuthSourceLdap.any_instance.stubs(:organizations).returns([taxonomies(:organization1)])
    AuthSourceLdap.any_instance.stubs(:locations).returns([taxonomies(:location1)])
    post :login, params: { :login => {'login' => 'ldap-user', 'password' => 'password'} }
    assert_redirected_to hosts_path
    assert_match /mail.*invalid/i, flash[:warning]

    # Subsequent redirects to the user edit page should preserve the warning
    user = User.unscoped.find_by_login('ldap-user')
    get :index, session: set_session_user.merge(:user => user.id)
    assert_redirected_to edit_user_path(user)

    get :edit, params: { :id => user.id }, session: set_session_user.merge(:user => user.id)
    assert_response :success
    assert_match /mail.*invalid/i, flash[:warning]
    assert_match /An email address is required/, flash[:error]
  end

  test "test email was deliver an email successfully" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    put :test_mail, params: { :id => user.id, :user => {:login => user.login}, :user_email => user.mail }, session: set_session_user
    mail = ActionMailer::Base.deliveries.detect { |delivery| delivery.subject =~ /Foreman test email/ }
    assert mail
  end

  test "test email deliver failed" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    MailNotification.any_instance.stubs(:deliver).raises(Net::SMTPFatalError, 'Exception message')
    put :test_mail, params: { :id => user.id, :user => {:login => "johnsmith"}, :user_email => "foo@bar.com" }, session: set_session_user
    assert_response :unprocessable_entity
  end

  test "test email should be delivered to user's email when no email param exists" do
    user = users(:one)
    put :test_mail, params: { :id => user.id, :user => {:login => user.login} }, session: set_session_user
    mail = ActionMailer::Base.deliveries.last
    assert mail.subject.include? "Foreman test email"
    assert_equal user.mail, mail.to[0]
  end

  test "test email should be delivered even when user is not admin" do
    user = users(:one)
    User.current = user
    put :test_mail, params: { :id => user.id, :user => {:login => user.login} }
    mail = ActionMailer::Base.deliveries.last
    assert mail.subject.include? "Foreman test email"
    assert_equal user.mail, mail.to[0]
  end

  context "when user is logged in" do
    test "#login redirects to previous url" do
      @previous_url = "/bookmarks"
      get :login, session: set_session_user
      request.env['HTTP_REFERER'] = @previous_url

      get :login
      assert_redirected_to @previous_url
    end

    test "#login if referer absent redirect to hosts_path" do
      request.env['HTTP_REFERER'] = nil

      get :login
      assert_redirected_to hosts_path
    end
  end

  context 'default taxonomies' do
    test 'accessing a regular page sets default taxonomies' do
      users(:one).update(:default_location_id => taxonomies(:location1).id,
                                    :default_organization_id => taxonomies(:organization1).id,
                                    :password                => 'changeme')

      get :index, session: set_session_user(:one)
      assert_equal session['organization_id'], users(:one).default_organization_id
      assert_equal session['location_id'],     users(:one).default_location_id
    end

    test 'users can update their own default taxonomies' do
      users(:one).update(:locations => [taxonomies(:location1)],
                                    :organizations => [taxonomies(:organization1)])

      put :update, params: { :id   => users(:one).id,
                             :user => { :default_location_id => taxonomies(:location1).id,
                                :default_organization_id => taxonomies(:organization1).id } }
      assert_redirected_to users_path

      updated_user = User.unscoped.find(users(:one).id)
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
      assert_raises ActionController::InvalidAuthenticityToken do
        post :logout, session: set_session_user
      end
    end

    test "allows logout when CSRF token is correct" do
      @controller.expects(:verify_authenticity_token).returns(true)
      post :logout, session: set_session_user
      assert_response :found
      assert_redirected_to "/users/login"
    end

    test "accessing logout page using GET should display confirmation" do
      get :logout, session: set_session_user
      assert_response :success
      assert @response.body.include?("Are you")
    end
  end

  test "#login respects session original_uri" do
    session[:original_uri] = '/realms'
    post :login, params: { :login => {'login' => users(:admin).login, 'password' => 'secret'} }
    assert_redirected_to realms_path
  end

  test "should impersonate a user" do
    session[:impersonated_by] = nil
    user = users(:one)
    get :impersonate, params: { :id => user.id }, session: set_session_user
    assert_redirected_to hosts_path
    assert flash.to_hash["success"]
  end

  test "should stop impersonating a user" do
    session[:impersonated_by] = users(:admin)
    get :stop_impersonation, session: set_session_user(:one)
    assert_response :success
    assert_equal "You now act as Admin User again.", JSON.parse(@response.body)['message']
  end

  context 'personal access tokens' do
    let(:user) { FactoryBot.create(:user) }
    let(:token) { FactoryBot.create(:personal_access_token, :user => user) }
    let(:token_value) do
      token_value = token.generate_token
      token.save
      token_value
    end

    test '#login does not allow login via personal access token' do
      post :login, params: { :login => {'login' => user.login, 'password' => token_value} }
      assert_redirected_to login_users_path
      assert flash[:inline][:error].present?
    end
  end
end
