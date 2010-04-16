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

    assert mod_user.matching_password? "dummy"
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

    assert  mod_user.matching_password? "changeme"
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
    delete :destroy, {:id => user}, {:user => users(:two)}
    assert_redirected_to users_url
    assert !User.exists?(user.id)
  end

  test "should not delete same user" do
    @request.env['HTTP_REFERER'] = users_path
    user = users(:one)
    delete :destroy, {:id => user}, {:user => user}
    assert_redirected_to users_url
    assert User.exists?(user.id)
    assert @response.flash[:foreman_notice] == "You are currently logged in, suicidal?"
  end

end
