require 'integration_test_helper'

class ApipieIntegrationTest < ActionDispatch::IntegrationTest
  test "Apipie docs URL should be successful" do
    get "/apidoc"
    assert_equal 200, status
  end

  test "Apipie DSL docs URL should be successful" do
    get "/templates_doc"
    assert_equal 200, status
  end
end
