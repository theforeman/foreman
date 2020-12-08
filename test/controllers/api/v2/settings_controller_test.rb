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

  test "validate show attributes" do
    get :show, params: { :id => settings(:attributes1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert_include show_response.keys, 'created_at'
    assert_include show_response.keys, 'updated_at'
  end

  test "should not update setting" do
    put :update, params: { :id => settings(:attributes1).to_param, :setting => { } }
    assert_response 422
  end

  test "should parse string values to integers" do
    setting_id = Setting.where(:settings_type => 'integer').first.id
    put :update, params: { :id => setting_id, :setting => { :value => "100" } }
    assert_response :success
    assert_equal 100, Setting.find(setting_id).value
  end

  test "should accept integer values" do
    setting_id = Setting.where(:settings_type => 'integer').first.id
    put :update, params: { :id => setting_id, :setting => { :value => 120 } }
    assert_response :success
    assert_equal 120, Setting.find(setting_id).value
  end

  test "should parse string values to ararys" do
    setting_id = Setting.where(:settings_type => 'array').first.id
    put :update, params: { :id => setting_id, :setting => { :value => "['baz','foo']" } }
    assert_response :success
    assert_equal ['baz', 'foo'], Setting.find(setting_id).value
  end

  test "should accept array values" do
    setting_id = Setting.where(:settings_type => 'array').first.id
    put :update, params: { :id => setting_id, :setting => { :value => ['foo', 'bar'] } }
    assert_response :success
    assert_equal ['foo', 'bar'], Setting.find(setting_id).value
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
