require 'test_helper'

class Api::V2::DashboardControllerTest < ActionController::TestCase
  test "should get index with json result" do
    get :index
    assert_response :success
    dashboard = ActiveSupport::JSON.decode(@response.body)
    assert_operator(dashboard.length, :>, 0)
  end

  test "should have glossary" do
    get :index
    assert_response :success
    dashboard = ActiveSupport::JSON.decode(@response.body)
    assert(dashboard["glossary"], 'Should have glossary')
    assert(dashboard["glossary"].is_a?(Hash), 'Glossary should have children')
    assert_equal(17, dashboard["glossary"].keys.length)
  end
end
