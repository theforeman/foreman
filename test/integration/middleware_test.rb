require 'integration_test_helper'

class MiddlewareIntegrationTest < ActionDispatch::IntegrationTest
  test "secure headers are set" do
    visit '/'
    assert_equal page.response_headers['X-Frame-Options'], 'sameorigin'
    assert_equal page.response_headers['X-XSS-Protection'], '1; mode=block'
    assert_equal page.response_headers['X-Content-Type-Options'], 'nosniff'
    assert_equal page.response_headers['Content-Security-Policy'], \
      "default-src 'self'; child-src 'self'; connect-src 'self' ws: wss:; "+
      "img-src 'self' data: *.gravatar.com; script-src 'unsafe-eval' 'unsafe-inline' "+
      "'self'; style-src 'unsafe-inline' 'self'"
  end

  test "webpack dev server adds the dev server to Content-Security-Policy" do
    begin
      Rails.configuration.webpack.dev_server.enabled = true
      Webpack::Rails::Manifest.stubs(:asset_paths).returns([])
      visit '/'
      assert page.response_headers['Content-Security-Policy'].include?(Rails.configuration.webpack.dev_server.port.to_s)
    ensure
      Rails.configuration.webpack.dev_server.enabled = false
    end
  end
end
