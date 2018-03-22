require 'test_helper'

class Api::V2::BookmarksControllerTest < ActionController::TestCase
  bookmark_base = {
    :public     => false,
    :controller => "hosts"
  }

  simple_bookmark = bookmark_base.merge({
                                          :name  => "foo-bar",
                                          :query => "bar"
                                        })

  dot_bookmark = bookmark_base.merge({
                                       :name  => "facts.architecture",
                                       :query => " facts.architecture = x86_64"
                                     })

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bookmarks)
  end

  test "should show bookmark" do
    get :show, params: { :id => bookmarks(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should create bookmark" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => simple_bookmark }
    end
    assert_response :created
  end

  test "should create bookmark with a dot" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => dot_bookmark }
    end
    assert_response :created
  end

  test "should update bookmark" do
    put :update, params: { :id => bookmarks(:one).to_param, :bookmark => dot_bookmark }
    assert_response :success
  end

  test "should destroy bookmark" do
    assert_difference('Bookmark.count', -1) do
      delete :destroy, params: { :id => bookmarks(:one).to_param }
    end
    assert_response :success
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
  end
end
