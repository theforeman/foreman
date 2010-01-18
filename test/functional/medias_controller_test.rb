require 'test_helper'

class MediasControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Media model" do
    assert_not_nil MediasController.active_scaffold_config
    assert MediasController.active_scaffold_config.model == Media
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "shuold get new" do
    get :new
    assert_response :success
  end

  test "should create new media" do
    assert_difference 'Media.count' do
      post :create, { :commit => "Create", :record => {:name => "some_arch", :path => "http://www.google.com"} }
    end

    assert_redirected_to medias_path
  end

  test "should get edit" do
    media = Media.new :name => "i386", :path => "http://www.google.com"
    assert media.save!

    get :edit, :id => media.id
    assert_response :success
  end

  test "should update media" do
    media = Media.new :name => "i386", :path => "http://www.google.com"
    assert media.save!

    put :update, { :commit => "Update", :id => media.id, :record => {:name => "other_media", :path => "http://www.vurbia.com"} }
    media = Media.find_by_id(media.id)
    assert media.name == "other_media"
    assert media.path == "http://www.vurbia.com"

    assert_redirected_to medias_path
  end

  test "should destroy media" do
    media = Media.new :name => "i386", :path => "http://www.google.com"
    assert media.save!

    assert_difference('Media.count', -1) do
      delete :destroy, :id => media.id
    end

    assert_redirected_to medias_path
  end
end
