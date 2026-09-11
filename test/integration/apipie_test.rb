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

  test "method page renders declared return values" do
    get "/apidoc/v2/settings/show.en.html"
    assert_equal 200, status
    assert_includes response.body, 'Returns'
    # full_name is documented only in the returns group of settings#show,
    # so its presence proves the returns table rendered
    assert_includes response.body, 'full_name'
  end
end
