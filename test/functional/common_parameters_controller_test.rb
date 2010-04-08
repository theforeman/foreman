require 'test_helper'

class CommonParametersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => CommonParameter.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to common_parameter_url(assigns(:common_parameter))
  end

  def test_edit
    get :edit, :id => CommonParameter.first
    assert_template 'edit'
  end

  def test_update_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    put :update, :id => CommonParameter.first
    assert_template 'edit'
  end

  def test_update_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    put :update, :id => CommonParameter.first
    assert_redirected_to common_parameter_url(assigns(:common_parameter))
  end

  def test_destroy
    common_parameter = CommonParameter.first
    delete :destroy, :id => common_parameter
    assert_redirected_to common_parameters_url
    assert !CommonParameter.exists?(common_parameter.id)
  end
end
