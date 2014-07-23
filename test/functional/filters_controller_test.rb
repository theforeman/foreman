require 'test_helper'

class FiltersControllerTest < ActionController::TestCase

  test 'get index' do
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:filters)
  end

  test 'get new' do
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  test "changes should expire topbar cache" do
    user1 = FactoryGirl.create(:user, :with_mail)
    user2 = FactoryGirl.create(:user, :with_mail)
    filter = FactoryGirl.create(:filter, :on_name_all)
    role = filter.role
    role.users = [user1, user2]
    role.save!

    User.any_instance.expects(:expire_topbar_cache).twice
    put :update, { :id => filter.id, :filter => {:role_id => role.id, :search => "name ~ a*"}}, set_session_user
  end


end
