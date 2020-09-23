require 'test_helper'
require 'nokogiri'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  test "can render a new sti type setting" do
    class Setting::Valid < Setting; end
    assert Setting.create(:name => "foo", :default => "bar", :description => "test foo", :category => "Setting::Valid")
    get :index, session: set_session_user
    assert_match /id='Valid'/, @response.body
  end

  test "does not render an old sti type setting" do
    assert setting = Setting.create(:name => "foo", :default => "bar", :description => "test foo")
    setting.send(:write_attribute, :category, "Setting::Invalid")
    get :index, session: set_session_user
    assert_no_match /id='Invalid'/, @response.body
  end
end
