require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Medium.any_instance.stubs(:valid?).returns(false)
    post :create, {:medium => {:name => nil}}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Medium.any_instance.stubs(:valid?).returns(true)
    post :create, {:medium => {:name => "MyMedia"}}, set_session_user
    assert_redirected_to media_url
  end

  def test_edit
    get :edit, {:id => Medium.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Medium.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Medium.first, :medium => {:name => nil}}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Medium.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Medium.first, :medium => {:name => "MyUpdatedMedia"}}, set_session_user
    assert_redirected_to media_url
  end

  def test_destroy
    medium = media(:unused)
    delete :destroy, {:id => medium}, set_session_user
    assert_redirected_to media_url
    assert !Medium.exists?(medium.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.find_by_name('Anonymous'), Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a medium' do
    setup_user
    get :edit, {:id => Medium.first.id}, set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing media' do
    setup_user
    get :index, {}, set_session_user.merge(:user => users(:one).id)
    assert_response :success
  end
end
