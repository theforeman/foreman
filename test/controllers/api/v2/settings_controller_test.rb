require 'test_helper'

class Api::V2::SettingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:settings)
    settings = ActiveSupport::JSON.decode(@response.body)
    assert !settings.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => settings(:attributes1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should not update setting" do
    put :update, params: { :id => settings(:attributes1).to_param, :setting => { } }
    assert_response 422
  end

  test "should parse string values" do
    setting_id = Setting.where(:settings_type => 'integer').first.id
    put :update, params: { :id => setting_id, :setting => { :value => "100" } }
    assert_response :success
    assert_equal 100, Setting.find(setting_id).value
  end

  test "settings shouldnt include ones about organizations when organizations are disabled" do
    SETTINGS[:organizations_enabled] = false
    get :index
    assert_response :success
    assert_no_match /default_organization/, @response.body
    assert_no_match /organization_fact/, @response.body
    SETTINGS[:organizations_enabled] = true
  end

  test "settings shouldnt include ones about locations when locations are disabled" do
    SETTINGS[:locations_enabled] = false
    get :index
    assert_response :success
    assert_no_match /default_location/, @response.body
    assert_no_match /location_fact/, @response.body
    SETTINGS[:locations_enabled] = true
  end

  test_attributes :pid => 'fb8b0bf1-b475-435a-926b-861aa18d31f1'
  test "should update login page footer text with long value" do
    value = RFauxFactory.gen_alpha 1000
    setting = Setting.find_by_name("login_text")
    put :update, params: { :id => setting.id, :setting => { :value => value } }
    assert_equal JSON.parse(@response.body)['value'], value, "Can't update login_text setting with valid value #{value}"
  end

  test_attributes :pid => '7a56f194-8bde-4dbf-9993-62eb6ab10733'
  test "should update login page footer text with empty value" do
    setting = Setting.find_by_name("login_text")
    put :update, params: { :id => setting.id, :setting => { :value => "" } }
    assert_equal JSON.parse(@response.body)['value'], "", "Can't update login_text setting with empty value"
  end

  test "settings list should show full name column" do
    get :index
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert response["results"][0].key?("full_name")
  end

  test "should update setting as system admin" do
    user = user_one_as_system_admin
    setting_id = Setting.where(:settings_type => 'integer').first.id
    as_user user do
      put :update, params: { :id => setting_id, :setting => { :value => "100" } }
    end
    assert_response :success
  end

  test "should view setting as system admin" do
    user = user_one_as_system_admin
    setting_id = Setting.first.id
    as_user user do
      get :show, params: { :id => setting_id }
    end
    assert_response :success
  end

  private

  def user_one_as_system_admin
    user = users(:one)
    user.roles = [Role.default, Role.find_by_name('System admin')]
    user
  end
end
