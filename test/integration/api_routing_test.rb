require 'integration_test_helper'

class RoutingIntegrationTest < ActionDispatch::IntegrationTest
  test "should go to v2 controller for /v2 passed in URL" do
    assert_recognizes({:controller => "api/v2/domains", :action => "index", :apiv => "v2", :format => "json"}, "/api/v2/domains")
  end
end
