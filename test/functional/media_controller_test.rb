require 'test_helper'

class MediaControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_index_json
    get :index, {:format => "json"}, set_session_user
    media = ActiveSupport::JSON.decode(@response.body)
    assert !media.empty?
    assert_response :success
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Medium.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Medium.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to media_url
  end

  def test_create_valid_json
    Medium.any_instance.stubs(:valid?).returns(true)
    post :create, {:format => "json"}, set_session_user
    medium = ActiveSupport::JSON.decode(@response.body)
    assert_response :created
  end

  def test_edit
    get :edit, {:id => Medium.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Medium.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Medium.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Medium.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Medium.first}, set_session_user
    assert_redirected_to media_url
  end

  def test_update_valid_json
    Medium.any_instance.stubs(:valid?).returns(true)
    put :update, {:format => "json", :id => Medium.first}, set_session_user
    medium = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
  end

  def test_destroy
    medium = media(:unused)
    delete :destroy, {:id => medium}, set_session_user
    assert_redirected_to media_url
    assert !Medium.exists?(medium.id)
  end

  def test_destroy_json
    medium = media(:unused)
    delete :destroy, {:format => "json", :id => medium}, set_session_user
    medium = ActiveSupport::JSON.decode(@response.body)
    assert_response :ok
    assert !Medium.exists?(:id => medium['id'])
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
