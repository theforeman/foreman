require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should get new" do
    get :new, {}, set_session_user
    assert_response :success
  end

  test "should create bookmark" do
    User.current = users(:one)
    assert_difference('Bookmark.count') do
      post :create, {:bookmark => {:name => "foo-bar", :query => "bar", :public => false, :controller => "hosts"}}, set_session_user
    end

    assert_redirected_to hosts_path
  end

  test "should create bookmark with a dot" do
    User.current = users(:one)
    assert_difference('Bookmark.count') do
      post :create, {:bookmark => {:name => "facts.architecture", :query => " facts.architecture = x86_64", :public => false, :controller => "hosts"}}, set_session_user
    end

    assert_redirected_to hosts_path
  end

  test "should get edit" do
    get :edit, {:id => bookmarks(:one).to_param}, set_session_user
    assert_response :success
  end

  test "should update bookmark" do
    put :update, {:id => bookmarks(:one).to_param, :bookmark => { :name => 'bar' }}, set_session_user
    assert_redirected_to bookmarks_path
  end

  test "should destroy bookmark" do
    assert_difference('Bookmark.count', -1) do
      delete :destroy, {:id => bookmarks(:one).to_param}, set_session_user
    end
    assert_redirected_to bookmarks_path
  end
end
