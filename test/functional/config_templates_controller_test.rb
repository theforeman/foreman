require 'test_helper'

class ConfigTemplatesControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_new
    get :new, {}, set_session_user
    assert_template 'new'
  end

  def test_create_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    post :create, {}, set_session_user
    assert_template 'new'
  end

  def test_create_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create, {}, set_session_user
    assert_redirected_to config_templates_url
  end

  def test_edit
    get :edit, {:id => ConfigTemplate.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => ConfigTemplate.first}, set_session_user
    assert_template 'edit'
  end

  def test_update_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => ConfigTemplate.first}, set_session_user
    assert_redirected_to config_templates_url
  end

  def test_destroy
    config_template = ConfigTemplate.first
    delete :destroy, {:id => config_template}, set_session_user
    assert_redirected_to config_templates_url
    assert !ConfigTemplate.exists?(config_template.id)
  end
end
