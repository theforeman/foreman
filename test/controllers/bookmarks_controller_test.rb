require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  setup do
    @factory_options = [{:controller => "users"}]
  end

  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test "should get index" do
    get :index, session: set_session_user
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should get edit" do
    get :edit, params: { :id => bookmarks(:one).to_param }, session: set_session_user
    assert_response :success
  end

  test "should update bookmark" do
    put :update, params: { :id => bookmarks(:one).to_param, :bookmark => { :name => 'bar' } }, session: set_session_user
    assert_redirected_to bookmarks_path
  end

  test "should destroy bookmark" do
    assert_difference('Bookmark.count', -1) do
      delete :destroy, params: { :id => bookmarks(:one).to_param }, session: set_session_user
    end
    assert_redirected_to bookmarks_path
  end

  test "should only show public and user's bookmarks" do
    get :index, session: set_session_user
    assert_response :success
    assert_includes assigns(:bookmarks), bookmarks(:one)
    refute_includes assigns(:bookmarks), bookmarks(:two)
  end

  test "should not allow actions on non public/non user bookmarks" do
    put :update, params: { :id => bookmarks(:two).to_param, :bookmark => { :name => 'bar' } }, session: set_session_user
    assert_response 404

    get :edit, params: { :id => bookmarks(:two).to_param }, session: set_session_user
    assert_response 404
  end

  test "should search by name" do
    get :index, params: { :search => "name=\"foo\"" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:bookmarks)
    assert assigns(:bookmarks).include?(bookmarks(:one))
  end

  test "should search by controller" do
    get :index, params: { :search => "controller=hosts" }, session: set_session_user
    assert_response :success
    refute_empty assigns(:bookmarks)
    assert assigns(:bookmarks).include?(bookmarks(:one))
  end
end
