require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_update_invalid
    Setting.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Setting.first, :format => "json"}, set_session_user
    assert_response :unprocessable_entity
  end

  def test_update_valid
    Setting.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Setting.first}, set_session_user
    assert_redirected_to settings_url
  end
end
