require 'test_helper'

class Api::V1::SettingsControllerTest < ActionController::TestCase
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

  test "should update setting" do
    put :update, params: { :id => settings(:attributes10).to_param, :setting => { } }
    assert_response :success
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
end
