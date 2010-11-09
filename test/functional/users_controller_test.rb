require 'test_helper'

class UsersControllerTest < ActionController::TestCase
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

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    put :update, { :commit => "Submit", :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.login == "johnsmith"
    assert_redirected_to users_path
  end

  test "should not remove the anonymous role" do
    user = User.create :login => "foo", :mail => "foo@bar.com", :auth_source => auth_sources(:one)

    assert user.roles = [roles :anonymous]

    put :update, { :commit => "Submit", :id => user.id, :user => {:login => "johnsmith"} }, set_session_user
    mod_user = User.find_by_id(user.id)

    assert mod_user.roles = [roles :anonymous]
  end

  test "should set password" do
    user = User.new :login => "foo", :mail => "foo@bar.com", :firstname => "john", :lastname => "smith", :auth_source => auth_sources(:internal)
    user.password = "changeme"
    assert user.save

    put :update, {:commit => "Submit", :id => user.id,
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

    put :update, {:commit => "Submit", :id => user.id,
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

    put :update, {:commit => "Submit", :id => user.id,
                  :user => { :login => "foobar" },
                 }, set_session_user

    assert_redirected_to users_url
  end

  test "should delete different user" do
    user = users(:one)
    delete :destroy, {:id => user}, {:user => users(:admin)}
    assert_redirected_to users_url
    assert !User.exists?(user.id)
  end

  test "should not delete same user" do
    return unless SETTINGS[:login]
    @request.env['HTTP_REFERER'] = users_path
    user = users(:one)
    user.update_attribute :admin, true
    delete :destroy, {:id => user.id}, {:user => user.id}
    assert_redirected_to users_url
    assert User.exists?(user)
    assert @response.flash[:foreman_notice] == "You are currently logged in, suicidal?"
  end

  test "should recreate the admin account" do
    return true unless SETTINGS[:login]
    return true unless SETTINGS[:login] == false
    User.find_by_login("admin").delete # Of course we only use destroy in the codebase
    assert User.find_by_login("admin").nil?
    get :index, {}, {:user => nil}
    assert !User.find_by_login("admin").nil?
  end

  def setup_users
    User.current = users :admin
    user = User.find_by_login("one")
    @request.session[:user] = user.id
    user.roles = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
    user.save!
  end

  test 'user with viewer rights should fail to edit a user' do
    setup_users
    get :edit, {:id => User.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing users' do
    setup_users
    get :index
    assert_response :success
  end
end
