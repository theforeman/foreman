require 'test_helper'

class Api::V2::SettingsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:settings)
    settings = ActiveSupport::JSON.decode(@response.body)
    assert !settings.empty?
  end

  test "should show individual record" do
    get :show, { :id => settings(:attributes1).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test "should update setting" do
    put :update, { :id => settings(:attributes1).to_param }
    assert_response :success
  end

  test "should parse string values" do
    setting_id = Setting.where(:settings_type => 'integer').first.id
    put :update, { :id => setting_id, :value => "100"  }
    assert_response :success
    assert_equal 100, Setting.find(setting_id).value
  end

end
