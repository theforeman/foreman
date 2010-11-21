require 'test_helper'

class ConfigTemplatesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to config_templates_url
  end

  def test_edit
    get :edit, :id => ConfigTemplate.first
    assert_template 'edit'
  end

  def test_update_invalid
    ConfigTemplate.any_instance.stubs(:valid?).returns(false)
    put :update, :id => ConfigTemplate.first
    assert_template 'edit'
  end

  def test_update_valid
    ConfigTemplate.any_instance.stubs(:valid?).returns(true)
    put :update, :id => ConfigTemplate.first
    assert_redirected_to config_templates_url
  end

  def test_destroy
    config_template = ConfigTemplate.first
    delete :destroy, :id => config_template
    assert_redirected_to config_templates_url
    assert !ConfigTemplate.exists?(config_template.id)
  end
end
