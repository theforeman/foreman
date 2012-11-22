require 'test_helper'

class Api::V1::SettingsControllerTest < ActionController::TestCase

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
    put :update, { :id => settings(:attributes1).to_param, :setting => { } }
    assert_response :success
  end

end
