require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get edit" do
    u = User.new :login => "foo", :mail => "foo@bar.com"
    assert u.save!
    logger.info "************ ID = #{u.id}"
    get :edit, :id => u.id
    #assert_response :success
  end

  test "should update user" do
    user = User.create :login => "foo", :mail => "foo@bar.com"

    put :update, { :commit => "Update", :id => user.id, :record => {:login => "johnsmith"} }
    mod_user = User.find_by_id(user.id)

    assert mod_user.login == "johnsmith"
    assert_redirected_to users_path
  end

  test "should get show" do
    u = User.create :login => "foo", :mail => "foo@bar.com"
    get :show, :id => u.id
    assert_not_nil assigns("record")
    assert_response :success
  end

  test "should delete" do
    u = User.create :login => "foo", :mail => "foo@bar.com"
    assert_difference('User.count', -1) do
      delete :destroy, :id => u.id
    end
  end
end
