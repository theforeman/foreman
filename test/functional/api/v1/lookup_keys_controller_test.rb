require 'test_helper'

class Api::V1::LookupKeysControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:lookup_keys)
    lookup_keys = ActiveSupport::JSON.decode(@response.body)
    assert !lookup_keys.empty?
  end
end
