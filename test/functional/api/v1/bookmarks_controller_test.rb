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
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should show bookmark" do
    as_user :admin do
      get :show, {:id => bookmarks(:one).to_param}
    end
    assert_response :success
  end

  test "should create bookmark" do
    as_user :one do
      assert_difference('Bookmark.count') do
        post :create, {:bookmark => simple_bookmark}
      end
    end
    assert_response :success
  end

  test "should create bookmark with a dot" do
    as_user :one do 
      assert_difference('Bookmark.count') do
        post :create, {:bookmark => dot_bookmark}
      end
    end
    assert_response :success
  end

  test "should update bookmark" do
    as_user :admin do 
      put :update, {:id => bookmarks(:one).to_param, :bookmark => {} }
    end
    assert_response :success
  end

  test "should destroy bookmark" do
    as_user :admin do
      assert_difference('Bookmark.count', -1) do
        delete :destroy, {:id => bookmarks(:one).to_param}
      end
    end
    assert_response :success
  end
end
