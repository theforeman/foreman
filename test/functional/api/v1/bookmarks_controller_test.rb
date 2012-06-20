require 'test_helper'

class Api::V1::BookmarksControllerTest < ActionController::TestCase


  bookmark_base = {
    :public => false, 
    :controller => "hosts"
  }

  simple_bookmark = bookmark_base.merge({
    :name => "foo-bar", 
    :query => "bar"
  })

  dot_bookmark = bookmark_base.merge({
    :name => "facts.architecture", 
    :query => " facts.architecture = x86_64"
  })


  test "should get index" do
    get :index, {}, set_session_user
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should show bookmark" do
    get :show, {:id => bookmarks(:one).to_param}, set_session_user
    assert_response :success
  end

  test "should create bookmark" do
    User.current = users(:one)
    assert_difference('Bookmark.count') do
      post :create, {:bookmark => simple_bookmark}, set_session_user
    end
    assert_response :success
  end

  test "should create bookmark with a dot" do
    User.current = users(:one)
    assert_difference('Bookmark.count') do
      post :create, {:bookmark => dot_bookmark}, set_session_user
    end
    assert_response :success
  end

  test "should update bookmark" do
    put :update, {:id => bookmarks(:one).to_param, :bookmark => {} }, set_session_user
    assert_response :success
  end

  test "should destroy bookmark" do
    assert_difference('Bookmark.count', -1) do
      delete :destroy, {:id => bookmarks(:one).to_param}, set_session_user
    end
    assert_response :success
  end
end
