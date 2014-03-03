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

  test "should create regular user" do
    post :create, {
      :user => {
        :login => "foo",
        :mail => "foo@bar.com",
      }
    }, set_session_user
    assert_equal @response.status, 200
  end

  test "should create admin user" do
    post :create, {
      :user => {
        :login => "foo",
        :admin => true,
        :mail => "foo@bar.com",
      }
    }, set_session_user
    assert_equal @response.status, 200
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    put :update, { :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.login == "johnsmith"
    assert_redirected_to users_path
  end

  def test_one #"should not remove the anonymous role" do
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

    assert  mod_user.matching_password?("changeme")
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
    assert_response 404
  end

  test 'user with edit permission should be able to edit another user' do
    setup_user 'edit', 'users'
    get :edit, { :id => users(:two) }
    assert_response :success
  end

  test 'user without edit permission should not be able to update another user' do
    User.current = users(:one)
    put :update, { :id => users(:two).id, :user => { :firstname => 'test' } }
    assert_response 403
  end

  test 'user with update permission should be able to update another user' do
    setup_user 'edit', 'users'
    put :update, { :id => users(:two).id, :user => { :firstname => 'test' } }

    assert_response :redirect
  end

end
