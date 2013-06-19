require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    setup_users
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
    put :update, {:id => User.admin.id, :user => { :locale => "cs" } }, set_session_user
    assert_redirected_to users_url
    assert User.admin.locale == "cs"
    put :update, { :id => User.admin.id, :user => { :locale => "" } }, set_session_user
    assert User.admin.locale.nil?
    assert session[:locale].nil?
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
    assert_equal @response.status, 403
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
     user = User.create :login => "mailess", :mail=> "", :auth_source => auth_sources(:one)

     update_hash = {"user"=>{
       "login"  => user.login,
       "mail"  => "you@have.mail"},
       "id"     => user.id}
     put :update, update_hash, set_session_user.merge(:user => user.id)

     assert !User.find_by_login(user.login).mail.blank?
   end

end
