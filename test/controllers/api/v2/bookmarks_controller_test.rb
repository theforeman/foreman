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

  test "should create bookmark with valid name and query" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => simple_bookmark }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['controller'], simple_bookmark[:controller], "Can't create bookmark with controller #{simple_bookmark[:controller]}"
    assert_equal JSON.parse(@response.body)['name'], simple_bookmark[:name], "Can't create bookmark with name #{simple_bookmark[:name]}"
    assert_equal JSON.parse(@response.body)['query'], simple_bookmark[:query], "Can't create bookmark with query #{simple_bookmark[:query]}"
  end

  test "should create bookmark with a dot" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => dot_bookmark }
    end
    assert_response :created
  end

  test "should create bookmark with public true" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => simple_bookmark }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['controller'], simple_bookmark[:controller], "Can't create bookmark with controller #{simple_bookmark[:controller]}"
    assert_equal JSON.parse(@response.body)['public'], simple_bookmark[:public], "Can't create bookmark with public #{simple_bookmark[:public]}"
  end

  test "should create bookmark with public false" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => simple_bookmark.merge(:public => false) }
    end
    assert_response :created
    assert_equal JSON.parse(@response.body)['controller'], simple_bookmark[:controller], "Can't create bookmark with controller #{simple_bookmark[:controller]}"
    assert_equal JSON.parse(@response.body)['public'], false, "Can't create bookmark with public false"
  end

  test "should update bookmark with public false" do
    put :update, params: { :id => bookmarks(:one).to_param, :bookmark => dot_bookmark }
    assert_response :success
    assert_equal JSON.parse(@response.body)['public'], false, "Can't update bookmark with public value false"
  end

  test "should update bookmark with public true" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => false)
    put :update, params: { :id => bookmark.id, :bookmark => {:public => true} }
    assert_response :success
    assert_equal JSON.parse(@response.body)['public'], true, "Can't update bookmark with public value true"
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

  test "should not create bookmark empty query" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:query => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not create bookmark empty public" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:public => nil) }
    end
    assert_response :unprocessable_entity
  end

  test "should not create bookmark with already taken name" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:name => bookmarks(:one).name) }
    end
    assert_response :unprocessable_entity
  end

  test "should not create bookmark with invalid name" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:name => '') }
    end
    assert_response :unprocessable_entity
  end

  test "should not update bookmark with empty query" do
    put :update, params: { :id => bookmarks(:one).id, :bookmark => simple_bookmark.merge(:query => '') }
    assert_response :unprocessable_entity
    bookmarks(:one).reload
    assert_not_equal '', bookmarks(:one).query
  end

  test "should not update bookmark with invalid name" do
    put :update, params: { :id => bookmarks(:one).id, :bookmark => simple_bookmark.merge(:name => '') }
    assert_response :unprocessable_entity
    bookmarks(:one).reload
    assert_not_equal '', bookmarks(:one).name
  end

  test "should not update bookmark with already taken name name" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => true)
    put :update, params: { :id => bookmarks(:one).id, :bookmark => simple_bookmark.merge(:name => bookmark.name) }
    assert_response :unprocessable_entity
    bookmarks(:one).reload
    assert_not_equal bookmark.name, bookmarks(:one).name
  end

  test "should not allow actions on non public/non user bookmarks" do
    put :update, params: { :id => bookmarks(:two).to_param, :bookmark => { :name => 'bar' } }, session: set_session_user
    assert_response 404
  end
end
