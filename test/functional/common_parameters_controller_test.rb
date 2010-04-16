require 'test_helper'

class CommonParametersControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_edit
    get :edit, {:id => CommonParameter.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    CommonParameter.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => CommonParameter.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    CommonParameter.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => CommonParameter.first}, set_session_user
    assert_redirected_to common_parameters_url
  end

  def test_destroy
    common_parameter = CommonParameter.first
    delete :destroy, {:id => common_parameter}, set_session_user
    assert_redirected_to common_parameters_url
    assert !CommonParameter.exists?(common_parameter.id)
  end
end
