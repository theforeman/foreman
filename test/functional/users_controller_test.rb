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

  test "should get edit" do
    u = User.new :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    assert u.save!
    logger.info "************ ID = #{u.id}"
    get :edit, {:id => u.id}, set_session_user
    assert_response :success
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
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    put :update, { :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.login == "johnsmith"
    assert_redirected_to users_path
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
    User.current = User.admin
    put :update, { :id => User.admin.id, :user => { :locale => "cs" } }, set_session_user
    assert_redirected_to users_url
    assert_equal "cs", User.admin.locale

    put :update, { :id => User.admin.id, :user => { :locale => "" } }, set_session_user
    assert_nil User.admin.locale
    assert_nil session[:locale]
  end

  test "should not delete same user" do
    return unless SETTINGS[:login]
    @request.env['HTTP_REFERER'] = users_path
    user = users(:one)
    user.update_attribute :admin, true
    delete :destroy, {:id => user.id}, set_session_user.merge(:user => user.id)
    assert_redirected_to users_url
    assert User.exists?(user)
    assert @request.flash[:notice] == "You are currently logged in, suicidal?"
  end

  test 'user with viewer rights should fail to edit a user' do
    get :edit, {:id => User.first.id}
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

  test "should set user as owner of hostgroup children if owner of hostgroup root" do
    User.current = User.first
    sample_user = users(:one)

    Hostgroup.new(:name => "root").save
    Hostgroup.new(:name => "first" , :parent_id => Hostgroup.find_by_name("root").id).save
    Hostgroup.new(:name => "second", :parent_id => Hostgroup.find_by_name("first").id).save

    update_hash = {"user"=>{ "login"         => sample_user.login,
      "hostgroup_ids" => ["", Hostgroup.find_by_name("root").id.to_s] },
      "id"            => sample_user.id }

    put :update, update_hash , set_session_user

    assert_equal Hostgroup.find_by_name("first").users.first , sample_user
    assert_equal Hostgroup.find_by_name("second").users.first, sample_user
  end

  test "should not be able to remove the admin flag from the admin account" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)
    user.admin = true
    user.save!

    target = users(:admin)
    update_hash = {"user"=>{
      "login"  => target.login,
      "admin"  => false},
      "id"     => target.id}
    put :update, update_hash, set_session_user.merge(:user => user.id)

    assert User.find_by_login(:admin).admin
    assert_template :edit
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
    @request.env['REMOTE_USER'] = 'admin'
    get :extlogin, {}, {}
    assert_redirected_to hosts_path
  end

  test "should login external user preserving uri" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache'
    @request.env['REMOTE_USER'] = 'admin'
    get :extlogin, {}, {:original_uri => '/test'}
    assert_redirected_to '/test'
  end

  test "should create and login external user" do
    Setting['authorize_login_delegation'] = true
    Setting['authorize_login_delegation_auth_source_user_autocreate'] = 'apache_mod'
    @request.env['REMOTE_USER'] = 'ares'
    get :extlogin, {}, {}
    assert_redirected_to edit_user_path(User.find_by_login('ares'))
  end

  test "should use intercept if available" do
    SSO::FormIntercept.any_instance.stubs(:available?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:authenticated?).returns(true)
    SSO::FormIntercept.any_instance.stubs(:current_user).returns(User.find_by_login('admin'))
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

  test "#login retains taxonomy session attributes in new session" do
    post :login, {:login => {'login' => users(:admin).login, 'password' => 'secret'}},
                 {:location_id => taxonomies(:location1).id,
                  :organization_id => taxonomies(:organization1).id,
                  :foo => 'bar'}
    assert_equal taxonomies(:location1).id, session[:location_id]
    assert_equal taxonomies(:organization1).id, session[:organization_id]
    refute session[:foo], "session contains 'foo', but should have been reset"
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
end
