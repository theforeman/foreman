require 'test_helper'

class RoutingIntegrationTest < ActionDispatch::IntegrationTest
  test "should go to v1 controller for /v1/ passed in URL" do
    assert_recognizes({:controller => "api/v1/domains", :action => "index", :apiv => "v1", :format => "json"}, "/api/v1/domains")
  end

  test "should go to v2 controller for /v2 passed in URL" do
    assert_recognizes({:controller => "api/v2/domains", :action => "index", :apiv => "v2", :format => "json"}, "/api/v2/domains")
  end
end
