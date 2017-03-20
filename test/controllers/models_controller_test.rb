require 'test_helper'

class ModelsControllerTest < ActionController::TestCase
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, session: set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    Model.any_instance.stubs(:valid?).returns(false)
    post :create, params: { :model => {:name => nil} }, session: set_session_user
    assert_template 'new'
  end

  def test_create_valid
    Model.any_instance.stubs(:valid?).returns(true)
    post :create, params: { :model => {:name => "test"} }, session: set_session_user
    assert_redirected_to models_url
  end

  def test_edit
    get :edit, params: { :id => Model.first }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    Model.any_instance.stubs(:valid?).returns(false)
    put :update, params: { :id => Model.first, :model => {:name => nil} }, session: set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    Model.any_instance.stubs(:valid?).returns(true)
    put :update, params: { :id => Model.first, :model => {:name => "updated test"} }, session: set_session_user
    assert_redirected_to models_url
  end

  def test_destroy
    model = Model.first
    delete :destroy, params: { :id => model }, session: set_session_user
    assert_redirected_to models_url
    assert !Model.exists?(model.id)
  end

  def setup_user
    @request.session[:user] = users(:one).id
    users(:one).roles       = [Role.default, Role.find_by_name('Viewer')]
  end

  test 'user with viewer rights should fail to edit a model' do
    setup_user
    get :edit, params: { :id => Model.first.id }, session: set_session_user.merge(:user => users(:one).id)
    assert_equal @response.status, 403
  end

  test 'user with viewer rights should succeed in viewing models' do
    setup_user
    get :index, session: set_session_user
    assert_response :success
  end
end
