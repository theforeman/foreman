require 'test_helper'

class Api::V2::BookmarksControllerTest < ActionController::TestCase
  bookmark_base = {
    :public     => false,
    :controller => "hosts",
  }

  simple_bookmark = bookmark_base.merge({
                                          :name  => "foo-bar",
                                          :query => "bar",
                                        })

  dot_bookmark = bookmark_base.merge({
                                       :name  => "facts.architecture",
                                       :query => " facts.architecture = x86_64",
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
    refute show_response.empty?
  end

  test "should create bookmark with valid name and query" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => simple_bookmark }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert_equal simple_bookmark[:controller], response['controller'], "Can't create bookmark with controller #{simple_bookmark[:controller]}"
    assert_equal simple_bookmark[:name], response['name'], "Can't create bookmark with name #{simple_bookmark[:name]}"
    assert_equal simple_bookmark[:query], response['query'], "Can't create bookmark with query #{simple_bookmark[:query]}"
  end

  test "should create bookmark with a dot" do
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => dot_bookmark }
    end
    assert_response :created
  end

  test "should create bookmark with public true" do
    bookmark_attr = simple_bookmark.merge(:public => true)
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => bookmark_attr }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert_equal bookmark_attr[:controller], response['controller'], "Can't create bookmark with controller #{bookmark_attr[:controller]}"
    assert_equal bookmark_attr[:public], response['public'], "Can't create bookmark with public #{bookmark_attr[:public]}"
  end

  test "should create bookmark with public false" do
    bookmark_attr = simple_bookmark.merge(:public => false)
    assert_difference('Bookmark.count') do
      post :create, params: { :bookmark => bookmark_attr }
    end
    assert_response :created
    response = JSON.parse(@response.body)
    assert_equal bookmark_attr[:controller], response['controller'], "Can't create bookmark with controller #{bookmark_attr[:controller]}"
    assert_equal bookmark_attr[:public], response['public'], "Can't create bookmark with public #{bookmark_attr[:public]}"
  end

  test "should update bookmark with public false" do
    put :update, params: { :id => bookmarks(:one).to_param, :bookmark => dot_bookmark }
    assert_response :success
    assert_equal false, JSON.parse(@response.body)['public'], "Can't update bookmark with public value false"
  end

  test "should update bookmark with public true" do
    bookmark = FactoryBot.create(:bookmark, :controller => "hosts", :public => false)
    put :update, params: { :id => bookmark.id, :bookmark => {:public => true} }
    assert_response :success
    assert_equal true, JSON.parse(@response.body)['public'], "Can't update bookmark with public value true"
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
    assert_match "Query can't be blank", @response.body
  end

  test "should not create bookmark empty public" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:public => nil) }
    end
    assert_response :unprocessable_entity
    assert_match 'Public is not included in the list', @response.body
  end

  test "should not create bookmark with already taken name" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:name => bookmarks(:one).name) }
    end
    assert_response :unprocessable_entity
    assert_match 'Name has already been taken', @response.body
  end

  test "should not create bookmark with invalid name" do
    assert_difference('Bookmark.count', 0) do
      post :create, params: { :bookmark => simple_bookmark.merge(:name => '') }
    end
    assert_response :unprocessable_entity
    assert_match "Name can't be blank", @response.body
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
