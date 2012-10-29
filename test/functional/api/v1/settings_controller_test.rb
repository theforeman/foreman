require 'test_helper'

class Api::V1::SettingsControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:settings)
    settings = ActiveSupport::JSON.decode(@response.body)
    assert !settings.empty?
  end
end
