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

  context 'webpack dev server is enabled' do
    setup do
      host_with_port = 'host:port'
      protocol = 'protocol'
      @webpack_url = "#{protocol}://#{host_with_port}"

      ApplicationController.any_instance.stubs(:should_allow_webpack?).returns(true)
      Webpacker.dev_server.stubs(:host_with_port).returns(host_with_port)
      Webpacker.dev_server.stubs(:protocol).returns(protocol)
    end

    test 'it is added the to Content-Security-Policy' do
      visit '/'
      assert page.response_headers['Content-Security-Policy'].include?(@webpack_url)
    end

    test 'it is added Content-Security-Policy on welcome pages' do
      Environment.stubs(:first).returns(nil)
      visit '/environments'
      assert page.has_content? 'Learn more about this in the documentation.'
      assert page.response_headers['Content-Security-Policy'].include?(@webpack_url)
    end

    context 'on unauthorized page requests' do
      test 'it is added to the Content-Security-Policy as well' do
        logout_admin
        visit '/environments'
        assert page.has_selector? 'input[name="login[password]"]'
        assert page.response_headers['Content-Security-Policy'].include?(@webpack_url)
      end
    end
  end
end
