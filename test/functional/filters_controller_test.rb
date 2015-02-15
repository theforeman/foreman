require 'test_helper'

class FiltersControllerTest < ActionController::TestCase
  setup do
    User.current = users(:admin)
  end

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

  test "should get index with role_id and create scoped search on role.name" do
    role = roles(:manager)
    get :index, {:role_id => role.id}, set_session_user
    assert_response :success
    refute_empty assigns(:filters)
    assert_equal Filter.search_for("role = #{role.name}").count, assigns(:filters).count
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create filter" do
    assert_difference('Filter.count') do
      post :create, {:filter => { :role_id => roles(:manager).id, :permission_ids => [permissions(:access_dashboard).id] }}, set_session_user
    end
    assert_redirected_to filters_path
  end

  test "should get edit" do
    get :edit, {:id => filters(:manager_1)}, set_session_user
    assert_response :success
  end

  test "should update filter" do
    put :update, {:id => filters(:manager_1), :filter => { :permission_ids => [permissions(:access_dashboard).id] }}, set_session_user
    assert_redirected_to filters_path
  end

  test "should destroy filter" do
    assert_difference('Filter.count', -1) do
      delete :destroy, {:id => filters(:manager_1)}, set_session_user
    end
    assert_redirected_to filters_path
  end
end
