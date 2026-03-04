require "test_helper"

class ForemanURLRendererTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
  end

  class Renderer
    include ActionView::Helpers
    include ActionDispatch::Routing
    include ::Foreman::ForemanURLRenderer

    attr_accessor :host, :template_url
  end

  let(:host) { FactoryBot.build_stubbed(:host, :managed, :with_dhcp_orchestration, :with_build) }
  let(:renderer) { Renderer.new }
  let(:action) { 'provision' }

  context 'with token' do
    let(:token) { '1234abc' }
    setup do
      host.build_token(:value => token, :expires => Time.zone.now + 5.minutes)
    end

    test "should render template_url with unattended url" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
    end

    test "should render template_url with unattended url with one raw param" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?token=#{token}&raw=${X}",
        renderer.foreman_url(action, {}, {raw: '${X}'})
    end

    test "should render template_url with unattended url with one param and one raw param" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?test=1&token=#{token}&raw=${X}",
        renderer.foreman_url(action, {test: 1},  {raw: '${X}'})
    end

    test "should render template_url with unattended url with a parameter" do
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?test=987&token=#{token}", renderer.foreman_url(action, test: 987)
    end

    test "should render template_url with unattended url with a parameter without a token" do
      host.stubs(:token).returns(nil)
      Setting[:unattended_url] = 'http://www.example.net'
      renderer.host = host
      assert_equal "#{Setting[:unattended_url]}/unattended/#{action}?test=987", renderer.foreman_url(action, test: 987)
    end

    test "should render template_url with template_url variable" do
      renderer.host = host
      renderer.template_url = "http://www.example.com"
      assert_equal "#{renderer.template_url}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
    end

    test "should render template_url with templates proxy" do
      template_server_from_proxy = 'https://someproxy:8443'
      proxy = FactoryBot.build_stubbed(:template_smart_proxy, :url => 'https://template.proxy:8443')

      stub_request(:get, "https://template.proxy:8443/unattended/templateServer").
         to_return(status: 200, body: "{\"templateServer\":\"#{template_server_from_proxy}\"}")

      host.subnet.template = proxy
      renderer.host = host
      assert_equal "#{template_server_from_proxy}/unattended/#{action}?token=#{token}", renderer.foreman_url(action)
      assert_requested(:get, "https://template.proxy:8443/unattended/templateServer", times: 1)
    end

    test "should render foreman request addr" do
      Setting[:unattended_url] = 'http://www.example.com'
      renderer.host = host
      assert_equal "www.example.com", renderer.foreman_request_addr
    end

    test "should render template_url for foreman request addr" do
      renderer.host = host
      renderer.template_url = "http://www.example.com"
      assert_equal "www.example.com", renderer.foreman_request_addr
    end
  end

  context '#force_url_https' do
    test "should convert HTTP to HTTPS" do
      url = "http://satellite.example.com/unattended/built?token=abc123"
      expected = "https://satellite.example.com/unattended/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should remove port 80 when converting to HTTPS" do
      url = "http://satellite.example.com:80/unattended/built?token=abc123"
      expected = "https://satellite.example.com/unattended/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should preserve custom HTTP port when converting to HTTPS" do
      url = "http://satellite.example.com:8080/unattended/built?token=abc123"
      expected = "https://satellite.example.com:8080/unattended/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should not modify already HTTPS URL" do
      url = "https://satellite.example.com/unattended/built?token=abc123"
      expected = "https://satellite.example.com/unattended/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should preserve custom HTTPS port" do
      url = "https://satellite.example.com:8443/unattended/built?token=abc123"
      expected = "https://satellite.example.com:8443/unattended/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should handle URL with path" do
      url = "http://satellite.example.com/some/path/built?token=abc123"
      expected = "https://satellite.example.com/some/path/built?token=abc123"
      assert_equal expected, renderer.force_url_https(url)
    end

    test "should handle URL without query parameters" do
      url = "http://satellite.example.com/unattended/built"
      expected = "https://satellite.example.com/unattended/built"
      assert_equal expected, renderer.force_url_https(url)
    end
  end
end
