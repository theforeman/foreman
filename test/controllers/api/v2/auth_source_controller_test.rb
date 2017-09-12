require 'test_helper'

class Api::V2::AuthSourceControllerTest < ActionController::TestCase

  test "should get index" do
    get :index, { }
    assert_response :success
    assert_not_nil assigns(:auth_source)
    auth_source = ActiveSupport::JSON.decode(@response.body)
    assert !auth_source.empty?
  end

  test "should show auth_source" do
    get :show, { :id => auth_sources(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end
end
