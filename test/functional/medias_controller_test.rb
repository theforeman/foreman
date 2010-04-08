require 'test_helper'

class MediasControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Media.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Media.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Media.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to media_url(assigns(:media))
  end

  def test_edit
    get :edit, :id => Media.first
    assert_template 'edit'
  end

  def test_update_invalid
    Media.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Media.first
    assert_template 'edit'
  end

  def test_update_valid
    Media.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Media.first
    assert_redirected_to media_url(assigns(:media))
  end

  def test_destroy
    media = Media.first
    delete :destroy, :id => media
    assert_redirected_to medias_url
    assert !Media.exists?(media.id)
  end
end
