require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_update_invalid
    Setting::General.any_instance.stubs(:valid?).returns(false)
    put :update, {:id => Setting::General.first, :format => "json"}, set_session_user
    assert_response :unprocessable_entity
  end

  def test_update_valid
    Setting::General.any_instance.stubs(:valid?).returns(true)
    put :update, {:id => Setting::General.first}, set_session_user
    assert_redirected_to settings_url
  end

  test "can render a new sti type setting" do
    class Setting::Valid < Setting ; end
    assert Setting.create(:name => "foo", :default => "bar", :description => "test foo", :category => "Setting::Valid")
    get :index, {}, set_session_user
    assert_match /id='Valid'/, @response.body
  end

  test "does not render an old sti type setting" do
    assert Setting.create(:name => "foo", :default => "bar", :description => "test foo", :category => "Setting::Invalid")
    get :index, {}, set_session_user
    assert_no_match /id='Invalid'/, @response.body
  end

end
