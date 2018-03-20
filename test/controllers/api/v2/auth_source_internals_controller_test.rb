require 'test_helper'

class Api::V2::AuthSourceInternalsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, params: { }
    assert_response :success
    assert_not_nil assigns(:auth_source_internals)
    auth_source_internals = ActiveSupport::JSON.decode(@response.body)
    refute_empty auth_source_internals
  end

  test "should show auth_source_internal" do
    get :show, params: { :id => auth_sources(:internal).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    refute_empty show_response
    assert_equal auth_sources(:internal).id, show_response['id']
  end
end
