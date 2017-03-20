require 'test_helper'

class Api::V1::AuditsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:audits)
    audits = ActiveSupport::JSON.decode(@response.body)
    assert !audits.empty?
  end

  test "should show individual record" do
    get :show, params: { :id => audits(:one).to_param }
    assert_response :success
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end
end
