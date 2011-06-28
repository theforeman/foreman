require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_edit
    get :edit, :id => Setting.first
    assert_template 'edit'
  end

  def test_update_invalid
    Setting.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Setting.first
    assert_template 'edit'
  end

  def test_update_valid
    Setting.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Setting.first
    assert_redirected_to settings_url
  end
end
