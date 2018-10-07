require 'test_helper'
require 'nokogiri'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, session: set_session_user
    assert_template 'index'
  end

  def test_update_valid
    Setting::General.any_instance.stubs(:valid?).returns(true)
    new_value = 'root@another.com'
    put :update, params: { :id => settings(:attributes1).to_param, :setting => {:value => new_value}, :format => :json }, session: set_session_user
    assert :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response.empty?
    assert_equal new_value, response['setting']['value']
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

  test "invalid inline edit of string on integer field" do
    put :update, params: { :id => settings(:attributes16).to_param, :setting => {:value => '25aaaa'}, :format => :json }, session: set_session_user
    assert_equal 'Value is not a number', assigns(:setting).errors.full_messages.first
    assert :unprocessable_entity
  end

  test "settings shouldnt include ones about organizations when organizations are disabled" do
    SETTINGS[:organizations_enabled] = false
    get :index, session: set_session_user
    html_doc = Nokogiri::HTML(response.body)
    assert_empty html_doc.css('span[data-original-title="default_organization"]')
    assert_no_match /organization_fact/, @response.body
    SETTINGS[:organizations_enabled] = true
  end

  test "settings shouldnt include ones about locations when locations are disabled" do
    SETTINGS[:locations_enabled] = false
    get :index, session: set_session_user
    html_doc = Nokogiri::HTML(response.body)
    assert_empty html_doc.css('span[data-original-title="default_location"]')
    assert_no_match /location_fact/, @response.body
    SETTINGS[:locations_enabled] = true
  end
end
