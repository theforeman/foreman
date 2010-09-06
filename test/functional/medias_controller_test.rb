require 'test_helper'

class MediasControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Media.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Media.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to medias_url
  end

  def test_edit
    get :edit, {:id => Media.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Media.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Media.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Media.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Media.first}, set_session_user
    assert_redirected_to medias_url
  end

  def test_destroy
    media = Media.first
    delete :destroy, {:id => media}, set_session_user
    assert_redirected_to medias_url
    assert !Media.exists?(media.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a media' do
    setup_user
    get :edit, {:id => Media.first.id}
    assert @response.status == '403 Forbidden'
  end

  test 'user with viewer rights should succeed in viewing medias' do
    setup_user
    get :index
    assert_response :success
  end
end
