require 'test_helper'

class Api::V1::ImagesControllerTest < ActionController::TestCase

  test "should get index" do
    as_user :admin do
      get :index, {}
    end
    assert_response :success
    assert_not_nil assigns(:images)
    images = ActiveSupport::JSON.decode(@response.body)
    assert !images.empty?
  end
end
