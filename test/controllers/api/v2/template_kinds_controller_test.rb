require 'test_helper'

class Api::V2::TemplateKindsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:template_kinds)
    template_kinds = ActiveSupport::JSON.decode(@response.body)
    assert !template_kinds.empty?
  end
end
