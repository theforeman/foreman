require 'test_helper'
require 'nokogiri'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  test "can render a new category setting" do
    duped_settings = Foreman::SettingManager.settings.dup
    Foreman::SettingManager.stubs(settings: duped_settings)
    Foreman::SettingManager.define(:test) do
      category(:valid, 'Valid') { setting('valid_foo', type: :string, default: 'bar', description: 'test foo') }
    end
    Foreman.settings.load
    get :index, session: set_session_user
    assert_match /id='valid'/, @response.body
  end

  test "does not render an old sti type setting" do
    assert setting = Setting.create(:name => "foo")
    setting.send(:write_attribute, :category, "Setting::Invalid")
    get :index, session: set_session_user
    assert_no_match /id='Invalid'/, @response.body
  end
end
